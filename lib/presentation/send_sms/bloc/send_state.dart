import 'package:equatable/equatable.dart';
import '../../../domain/entities/send_progress.dart';

abstract class SendState extends Equatable {
  const SendState();
  @override
  List<Object?> get props => [];
}

class SendIdle extends SendState {}

class SendRequestingPermission extends SendState {}

class SendPermissionDenied extends SendState {}

class SendInProgress extends SendState {
  final SendProgress progress;
  const SendInProgress(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SendPaused extends SendState {
  final SendProgress progress;
  const SendPaused(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SendCompleted extends SendState {
  final SendProgress progress;
  const SendCompleted(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SendCancelled extends SendState {
  final SendProgress progress;
  const SendCancelled(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SendError extends SendState {
  final String message;
  const SendError(this.message);
  @override
  List<Object?> get props => [message];
}
