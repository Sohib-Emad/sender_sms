import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'send_event.dart';
import 'send_state.dart';
import '../../../data/datasources/sms/sms_service.dart';
import '../../../domain/entities/send_progress.dart';
import '../../../domain/usecases/send_sms_batch_usecase.dart';
import '../../../domain/repositories/settings_repository.dart';

class SendBloc extends Bloc<SendEvent, SendState> {
  final SendSmsBatchUseCase _sendBatchUseCase;
  final SmsService _smsService;
  final SettingsRepository _settingsRepository;
  static const _uuid = Uuid();

  StreamSubscription<SendProgress>? _sendSubscription;
  SendProgress? _lastProgress;
  bool _isPaused = false;
  bool _isCancelled = false;
  // Queue for paused mode
  final List<SendProgress> _pausedQueue = [];

  SendBloc(this._sendBatchUseCase, this._smsService, this._settingsRepository)
      : super(SendIdle()) {
    on<SendStartBatch>(_onStart);
    on<SendPause>(_onPause);
    on<SendResume>(_onResume);
    on<SendCancel>(_onCancel);
    on<SendReset>(_onReset);
  }

  Future<void> _onStart(SendStartBatch event, Emitter<SendState> emit) async {
    emit(SendRequestingPermission());

    // Request SMS permission
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      emit(SendPermissionDenied());
      return;
    }

    // Check if app is default SMS app (required on Android 14+)
    final isDefault = await _smsService.isDefaultSmsApp();
    if (!isDefault) {
      emit(SendNotDefaultSmsApp());
      return;
    }

    _isPaused = false;
    _isCancelled = false;
    _lastProgress = null;
    final sessionId = _uuid.v4();

    final settings = await _settingsRepository.getSettings();

    final progress = SendProgress(
      total: event.students.length,
      sessionId: sessionId,
      isRunning: true,
    );
    emit(SendInProgress(progress));

    await emit.forEach<SendProgress>(
      _sendBatchUseCase(
        students: event.students,
        template: event.template,
        settings: settings,
        sessionId: sessionId,
      ),
      onData: (progress) {
        _lastProgress = progress;
        if (progress.isCompleted) {
          return SendCompleted(progress);
        } else if (progress.isCancelled) {
          return SendCancelled(progress);
        } else {
          return SendInProgress(progress);
        }
      },
      onError: (e, _) => SendError(e.toString()),
    );
  }

  void _onPause(SendPause event, Emitter<SendState> emit) {
    if (state is SendInProgress) {
      _isPaused = true;
      final progress = (state as SendInProgress).progress;
      emit(SendPaused(progress));
    }
  }

  void _onResume(SendResume event, Emitter<SendState> emit) {
    if (state is SendPaused) {
      _isPaused = false;
      final progress = (state as SendPaused).progress;
      emit(SendInProgress(progress));
    }
  }

  void _onCancel(SendCancel event, Emitter<SendState> emit) {
    _isCancelled = true;
    _sendSubscription?.cancel();
    final progress = _lastProgress ?? const SendProgress();
    emit(SendCancelled(progress));
  }

  void _onReset(SendReset event, Emitter<SendState> emit) {
    _sendSubscription?.cancel();
    _lastProgress = null;
    emit(SendIdle());
  }

  @override
  Future<void> close() {
    _sendSubscription?.cancel();
    return super.close();
  }
}
