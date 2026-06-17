import '../entities/student.dart';
import '../entities/app_settings.dart';
import '../entities/send_progress.dart';
import '../entities/sms_log.dart';
import '../entities/sms_session.dart';
import '../repositories/sms_repository.dart';
import '../../data/datasources/sms/sms_service.dart';
import 'package:uuid/uuid.dart';

class SendSmsBatchUseCase {
  final SmsRepository _smsRepository;
  final SmsService _smsService;
  static const _uuid = Uuid();

  SendSmsBatchUseCase(this._smsRepository, this._smsService);

  Stream<SendProgress> call({
    required List<Student> students,
    required String template,
    required AppSettings settings,
    required String sessionId,
  }) async* {
    int sent = 0;
    int failed = 0;
    bool cancelled = false;
    List<LogEntry> recentLogs = [];

    // Save initial session
    final session = SmsSession(
      id: sessionId,
      date: DateTime.now(),
      total: students.length,
      success: 0,
      failed: 0,
      templateUsed: template,
      status: 'in_progress',
    );
    await _smsRepository.saveSession(session);

    yield SendProgress(
      total: students.length,
      sent: 0,
      failed: 0,
      isRunning: true,
      sessionId: sessionId,
    );

    for (int i = 0; i < students.length; i++) {
      // Check for pause/cancel - these are checked via external stream control

      final student = students[i];

      // Build message from template
      final message = template
          .replaceAll('{name}', student.name)
          .replaceAll('{degree}', student.degree)
          .replaceAll('{phone}', student.phone);

      yield SendProgress(
        total: students.length,
        sent: sent,
        failed: failed,
        currentStudentName: student.name,
        currentPhone: student.phone,
        isRunning: true,
        sessionId: sessionId,
        recentLogs: recentLogs,
      );

      // Send SMS
      bool success = false;
      String? error;

      try {
        success = await _smsService.sendSms(
          to: student.phone,
          message: message,
          simSlot: settings.simSlot,
        );
        if (!success) error = 'فشل الإرسال';
      } catch (e) {
        success = false;
        error = e.toString();
      }

      // Update counters
      if (success) {
        sent++;
      } else {
        failed++;
      }

      // Log
      final logEntry = LogEntry(
        studentName: student.name,
        phone: student.phone,
        success: success,
        error: error,
        time: DateTime.now(),
      );
      recentLogs = [logEntry, ...recentLogs.take(49)];

      // Save to Hive
      await _smsRepository.saveLog(SmsLog(
        id: _uuid.v4(),
        sessionId: sessionId,
        studentName: student.name,
        phone: student.phone,
        message: message,
        status: success ? 'sent' : 'failed',
        errorMessage: error,
        sentAt: DateTime.now(),
      ));

      // Delay between messages (min 500ms to avoid Android rate limiter)
      if (i < students.length - 1) {
        final delay = settings.delaySeconds > 0 ? settings.delaySeconds : 0.5;
        await Future.delayed(Duration(milliseconds: (delay * 1000).toInt()));
      }
    }

    // Update final session
    final finalSession = session.copyWith(
      success: sent,
      failed: failed,
      status: 'completed',
    );
    await _smsRepository.updateSession(finalSession);

    yield SendProgress(
      total: students.length,
      sent: sent,
      failed: failed,
      isCompleted: !cancelled,
      isCancelled: cancelled,
      sessionId: sessionId,
      recentLogs: recentLogs,
    );
  }
}
