import '../../domain/entities/sms_session.dart';
import '../../domain/entities/sms_log.dart';
import '../../domain/repositories/sms_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/sms_session_model.dart';
import '../models/sms_log_model.dart';

class SmsRepositoryImpl implements SmsRepository {
  final HiveDatasource _datasource;

  SmsRepositoryImpl(this._datasource);

  @override
  Future<void> saveSession(SmsSession session) async {
    await _datasource.saveSession(SmsSessionModel.fromEntity(session));
  }

  @override
  Future<void> updateSession(SmsSession session) async {
    await _datasource.saveSession(SmsSessionModel.fromEntity(session));
  }

  @override
  Future<List<SmsSession>> getSessions() async {
    return _datasource.getAllSessions().map((m) => m.toEntity()).toList();
  }

  @override
  Future<SmsSession?> getSession(String id) async {
    return _datasource.getSession(id)?.toEntity();
  }

  @override
  Future<void> saveLog(SmsLog log) async {
    await _datasource.saveLog(SmsLogModel.fromEntity(log));
  }

  @override
  Future<void> saveLogs(List<SmsLog> logs) async {
    await _datasource.saveLogs(logs.map(SmsLogModel.fromEntity).toList());
  }

  @override
  Future<List<SmsLog>> getLogsBySession(String sessionId) async {
    return _datasource
        .getLogsBySession(sessionId)
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<List<SmsLog>> getFailedLogs(String sessionId) async {
    return _datasource
        .getFailedLogs(sessionId)
        .map((m) => m.toEntity())
        .toList();
  }
}
