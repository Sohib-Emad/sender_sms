import 'package:sender_sms/features/history/data/models/sms_session.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';

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

class SmsRepositoryImpl implements SmsRepository {
  final HiveDatasource _datasource;
  SmsRepositoryImpl(this._datasource);

  @override
  Future<void> saveSession(SmsSession session) async =>
      _datasource.saveSession(session);

  @override
  Future<void> updateSession(SmsSession session) async =>
      _datasource.saveSession(session);

  @override
  Future<List<SmsSession>> getSessions() async => _datasource.getAllSessions();

  @override
  Future<SmsSession?> getSession(String id) async => _datasource.getSession(id);

  @override
  Future<void> saveLog(SmsLog log) async => _datasource.saveLog(log);

  @override
  Future<void> saveLogs(List<SmsLog> logs) async => _datasource.saveLogs(logs);

  @override
  Future<List<SmsLog>> getLogsBySession(String sessionId) async =>
      _datasource.getLogsBySession(sessionId);

  @override
  Future<List<SmsLog>> getFailedLogs(String sessionId) async =>
      _datasource.getFailedLogs(sessionId);
}
