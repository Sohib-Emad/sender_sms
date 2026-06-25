import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:sender_sms/core/services/firebase_reporting_service.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';
import 'package:sender_sms/features/history/data/models/sms_session.dart';
import 'package:sender_sms/features/history/data/repos/sms_repository.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';
import 'package:sender_sms/features/send_sms/data/models/sms_result.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';

class SendSmsBatchUseCase {
  final SmsRepository _smsRepository;
  final SmsService _smsService;
  final FirebaseReportingService _reporting;
  static const _uuid = Uuid();

  SendSmsBatchUseCase(this._smsRepository, this._smsService, this._reporting);

  Stream<SendProgress> call({
    required List<Student> students,
    required String template,
    required AppSettings settings,
    required String sessionId,
    required bool Function() isPaused,
    required bool Function() isCancelled,
    required bool Function() shouldRetry,
    required bool Function() shouldSkip,
    required void Function(String error) onFailure,
  }) async* {
    int sent = 0, failed = 0;
    bool cancelled = false;
    List<LogEntry> recentLogs = [];
    final phonesContacted = <String>[];

    final session = SmsSession(
      id: sessionId, date: DateTime.now(), total: students.length,
      success: 0, failed: 0, templateUsed: template, status: 'in_progress',
    );
    await _smsRepository.saveSession(session);

    yield SendProgress(total: students.length, sessionId: sessionId, isRunning: true);

    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final message = template
          .replaceAll('{name}', student.name)
          .replaceAll('{degree}', student.degree)
          .replaceAll('{phone}', student.phone);

      bool retry = false;
      do {
        retry = false;
        if (isCancelled()) { cancelled = true; break; }
        while (isPaused()) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (isCancelled()) { cancelled = true; break; }
        }
        if (cancelled) break;

        // إظهار "جارٍ إرسال" للطالب الحالي قبل الإرسال الفعلي
        yield SendProgress(
          total: students.length, sent: sent, failed: failed,
          currentStudentName: student.name, currentPhone: student.phone,
          isRunning: true, sessionId: sessionId, recentLogs: recentLogs,
        );

        final SmsResult result = await _smsService.sendSms(
          to: student.phone, message: message, simSlot: settings.simSlot,
        );

        if (!result.success) {
          if (settings.autoSkipFailed) {
            failed++;
            recentLogs = [
              LogEntry(studentName: student.name, phone: student.phone,
                  success: false, error: result.errorMessage, time: DateTime.now()),
              ...recentLogs.take(49),
            ];
            await _saveSmsLog(sessionId, student, message, result);
            // فترة تهدئة 5 ثوانٍ بعد الفشل التلقائي لمنع تراكم الطلبات
            await Future.delayed(const Duration(seconds: 5));
          } else {
            // إرسال حالة الفشل الحالية لواجهة المستخدم وتفعيل الانتظار
            yield SendProgress(
              total: students.length, sent: sent, failed: failed,
              currentStudentName: student.name, currentPhone: student.phone,
              isRunning: true, sessionId: sessionId, recentLogs: recentLogs,
              isError: true, errorMessage: result.errorMessage ?? 'فشل إرسال الرسالة',
            );

            onFailure(result.errorMessage ?? 'فشل إرسال الرسالة');

            while (true) {
              if (isCancelled()) { cancelled = true; break; }
              if (shouldRetry()) {
                retry = true;
                break;
              }
              if (shouldSkip()) {
                failed++;
                recentLogs = [
                  LogEntry(studentName: student.name, phone: student.phone,
                      success: false, error: result.errorMessage, time: DateTime.now()),
                  ...recentLogs.take(49),
                ];
                await _saveSmsLog(sessionId, student, message, result);
                // فترة تهدئة 5 ثوانٍ بعد التخطي اليدوي
                await Future.delayed(const Duration(seconds: 5));
                break;
              }
              await Future.delayed(const Duration(milliseconds: 200));
            }
          }
        } else {
          sent++;
          phonesContacted.add(student.phone);
          recentLogs = [
            LogEntry(studentName: student.name, phone: student.phone,
                success: true, time: DateTime.now()),
            ...recentLogs.take(49),
          ];
          await _saveSmsLog(sessionId, student, message, result);
        }
      } while (retry);

      if (cancelled) break;

      if (i < students.length - 1) {
        final delay = settings.delaySeconds > 0 ? settings.delaySeconds : 10.0;
        await Future.delayed(Duration(milliseconds: (delay * 1000).toInt()));
      }
    }

    final status = cancelled ? 'cancelled' : 'completed';
    await _smsRepository.updateSession(session.copyWith(success: sent, failed: failed, status: status));

    // إرسال إحصائيات لـ Firebase في الخلفية (أرقام فقط)
    if (sent > 0 || failed > 0) {
      _reporting.submitSession(
        sessionId: sessionId, total: students.length,
        sent: sent, failed: failed, phonesContacted: phonesContacted,
      ).catchError((_) {});
    }

    yield SendProgress(
      total: students.length, sent: sent, failed: failed,
      isCompleted: !cancelled,
      isCancelled: cancelled,
      sessionId: sessionId, recentLogs: recentLogs,
    );
  }

  Future<void> _saveSmsLog(String sessionId, Student s, String msg, SmsResult r) =>
      _smsRepository.saveLog(SmsLog(
        id: _uuid.v4(), sessionId: sessionId, studentName: s.name,
        phone: s.phone, message: msg,
        status: r.success ? 'sent' : 'failed', errorMessage: r.errorMessage,
        sentAt: DateTime.now(),
      ));
}
