import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';

abstract class SendState extends Equatable {
  const SendState();
  @override
  List<Object?> get props => [];
}

class SendIdle extends SendState {}

class SendRequestingPermission extends SendState {}

class SendNotDefaultSmsApp extends SendState {}

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

class SendLowBalance extends SendState {
  final SendProgress progress;
  const SendLowBalance(this.progress);
  @override
  List<Object?> get props => [progress];
}

class SendError extends SendState {
  final String message;
  const SendError(this.message);
  @override
  List<Object?> get props => [message];
}

class SendGeneralError extends SendState {
  final SendProgress progress;
  const SendGeneralError(this.progress);
  @override
  List<Object?> get props => [progress];
}
