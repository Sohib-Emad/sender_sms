import '../repositories/sms_repository.dart';
import '../entities/sms_session.dart';
import '../entities/sms_log.dart';

class GetSessionsUseCase {
  final SmsRepository _repository;
  GetSessionsUseCase(this._repository);

  Future<List<SmsSession>> call() => _repository.getSessions();
}

class GetSessionLogsUseCase {
  final SmsRepository _repository;
  GetSessionLogsUseCase(this._repository);

  Future<List<SmsLog>> call(String sessionId) =>
      _repository.getLogsBySession(sessionId);
}

class GetFailedLogsUseCase {
  final SmsRepository _repository;
  GetFailedLogsUseCase(this._repository);

  Future<List<SmsLog>> call(String sessionId) =>
      _repository.getFailedLogs(sessionId);
}
