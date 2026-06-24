import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/settings/data/repos/settings_repository.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';
import 'send_sms_batch_usecase.dart';
import 'package:sender_sms/features/send_sms/logic/send_state.dart';

class SendCubit extends Cubit<SendState> {
  final SendSmsBatchUseCase _sendBatchUseCase;
  final SmsService _smsService;
  final SettingsRepository _settingsRepository;
  static const _uuid = Uuid();

  bool _isPaused = false;
  bool _isCancelled = false;
  SendProgress? _lastProgress;

  SendCubit(this._sendBatchUseCase, this._smsService, this._settingsRepository)
      : super(SendIdle());

  Future<void> startBatch({
    required List<Student> students,
    required String template,
    bool forcePermission = false,
  }) async {
    emit(SendRequestingPermission());
    try {
      final isDefault = await _smsService.isDefaultSmsApp();
      if (!isDefault && !forcePermission) {
        emit(SendNotDefaultSmsApp());
        return;
      }
      if (!isDefault) {
        final status = await Permission.sms.request();
        if (!status.isGranted) {
          emit(SendPermissionDenied());
          return;
        }
      }

      _isPaused = false;
      _isCancelled = false;
      _lastProgress = null;
      final sessionId = _uuid.v4();
      final settings = await _settingsRepository.getSettings();
      final progress = SendProgress(total: students.length, sessionId: sessionId, isRunning: true);
      emit(SendInProgress(progress));

      await for (final p in _sendBatchUseCase(
        students: students,
        template: template,
        settings: settings,
        sessionId: sessionId,
        isPaused: () => _isPaused,
        isCancelled: () => _isCancelled,
        onLowBalance: () => emit(SendLowBalance(_lastProgress ?? progress)),
      )) {
        _lastProgress = p;
        if (p.isLowBalance) {
          emit(SendLowBalance(p));
        } else if (p.isError) {
          emit(SendGeneralError(p));
        } else if (p.isCompleted) {
          emit(SendCompleted(p));
        } else if (p.isCancelled) {
          emit(SendCancelled(p));
        } else {
          emit(_isPaused ? SendPaused(p) : SendInProgress(p));
        }
      }
    } catch (e) {
      emit(SendError(e.toString()));
    }
  }

  void pause() {
    final cur = state;
    if (cur is SendInProgress) {
      _isPaused = true;
      emit(SendPaused(cur.progress));
    }
  }

  void resume() {
    final cur = state;
    if (cur is SendPaused) {
      _isPaused = false;
      emit(SendInProgress(cur.progress));
    }
  }

  void cancel() {
    _isCancelled = true;
    emit(SendCancelled(_lastProgress ?? const SendProgress()));
  }

  void reset() => emit(SendIdle());
}
