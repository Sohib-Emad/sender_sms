
import '../../data/datasources/excel/excel_service.dart';
import '../repositories/sms_repository.dart';

class ExportReportUseCase {
  final SmsRepository _smsRepository;
  ExportReportUseCase(this._smsRepository);

  Future<String> call(String sessionId) async {
    final session = await _smsRepository.getSession(sessionId);
    if (session == null) throw Exception('الجلسة غير موجودة');

    final logs = await _smsRepository.getLogsBySession(sessionId);

    return await ExcelService.exportReport(
      session: session,
      logs: logs,
    );
  }
}
