import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sender_sms/features/failed_messages/logic/failed_state.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';
import 'package:sender_sms/features/history/data/repos/sms_repository.dart';
import 'package:sender_sms/features/settings/data/repos/settings_repository.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/core/utils/extensions.dart';


class FailedCubit extends Cubit<FailedState> {
  final SmsRepository _smsRepository;
  final SettingsRepository _settingsRepository;
  final SmsService _smsService;

  FailedCubit(this._smsRepository, this._settingsRepository, this._smsService)
      : super(FailedInitial());

  Future<void> loadFailedLogs(String sessionId) async {
    emit(FailedLoading());
    try {
      final logs = await _smsRepository.getFailedLogs(sessionId);
      emit(FailedLoaded(logs));
    } catch (e) {
      emit(FailedError(e.toString()));
    }
  }

  Future<bool> retrySingle(SmsLog log) async {
    try {
      final isDefault = await _smsService.isDefaultSmsApp();
      if (!isDefault) {
        final status = await Permission.sms.request();
        if (!status.isGranted) return false;
      }

      final settings = await _settingsRepository.getSettings();
      final result = await _smsService.sendSms(
        to: log.phone.normalizeEgyptianPhone,
        message: log.message,
        simSlot: settings.simSlot,
      );

      if (result.success) {
        final updatedLog = log.copyWith(status: 'sent', errorMessage: null);
        await _smsRepository.saveLog(updatedLog);

        final session = await _smsRepository.getSession(log.sessionId);
        if (session != null) {
          final updatedSession = session.copyWith(
            success: session.success + 1,
            failed: session.failed - 1,
          );
          await _smsRepository.updateSession(updatedSession);
        }
        await loadFailedLogs(log.sessionId);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
