

import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';

abstract class FailedState extends Equatable {
  const FailedState();
  @override
  List<Object?> get props => [];
}

class FailedInitial extends FailedState {}

class FailedLoading extends FailedState {}

class FailedLoaded extends FailedState {
  final List<SmsLog> failedLogs;
  const FailedLoaded(this.failedLogs);
  @override
  List<Object?> get props => [failedLogs];
}

class FailedError extends FailedState {
  final String message;
  const FailedError(this.message);
  @override
  List<Object?> get props => [message];
}