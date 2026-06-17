import '../../domain/entities/sms_session.dart';
import '../../domain/entities/sms_log.dart';

abstract class SmsRepository {
  Future<void> saveSession(SmsSession session);
  Future<void> updateSession(SmsSession session);
  Future<List<SmsSession>> getSessions();
  Future<SmsSession?> getSession(String id);

  Future<void> saveLog(SmsLog log);
  Future<void> saveLogs(List<SmsLog> logs);
  Future<List<SmsLog>> getLogsBySession(String sessionId);
  Future<List<SmsLog>> getFailedLogs(String sessionId);
}
