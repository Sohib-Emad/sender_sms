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
    void Function()? onLowBalance,
  }) async* {
    int sent = 0, failed = 0;
    bool cancelled = false, lowBalance = false, hasError = false;
    String? errorMessage;
    List<LogEntry> recentLogs = [];
    final phonesContacted = <String>[];

    final session = SmsSession(
      id: sessionId, date: DateTime.now(), total: students.length,
      success: 0, failed: 0, templateUsed: template, status: 'in_progress',
    );
    await _smsRepository.saveSession(session);

    yield SendProgress(total: students.length, sessionId: sessionId, isRunning: true);

    for (int i = 0; i < students.length; i++) {
      if (isCancelled()) { cancelled = true; break; }
      while (isPaused()) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (isCancelled()) { cancelled = true; break; }
      }
      if (cancelled) break;

      final student = students[i];
      final message = template
          .replaceAll('{name}', student.name)
          .replaceAll('{degree}', student.degree)
          .replaceAll('{phone}', student.phone);

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
        failed++;
        recentLogs = [
          LogEntry(studentName: student.name, phone: student.phone,
              success: false, error: result.errorMessage, time: DateTime.now()),
          ...recentLogs.take(49),
        ];
        await _saveSmsLog(sessionId, student, message, result);

        if (result.isLowBalance) {
          lowBalance = true;
          onLowBalance?.call();
        } else {
          hasError = true;
          errorMessage = result.errorMessage ?? 'فشل إرسال الرسالة';
        }
        break;
      }

      sent++;
      phonesContacted.add(student.phone);
      recentLogs = [
        LogEntry(studentName: student.name, phone: student.phone,
            success: true, time: DateTime.now()),
        ...recentLogs.take(49),
      ];
      await _saveSmsLog(sessionId, student, message, result);

      if (i < students.length - 1) {
        final delay = settings.delaySeconds > 0 ? settings.delaySeconds : 2.0;
        await Future.delayed(Duration(milliseconds: (delay * 1000).toInt()));
      }
    }

    final status = lowBalance ? 'low_balance' : (hasError ? 'failed' : (cancelled ? 'cancelled' : 'completed'));
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
      isCompleted: !cancelled && !lowBalance && !hasError,
      isCancelled: cancelled, isLowBalance: lowBalance,
      isError: hasError, errorMessage: errorMessage,
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
