import 'package:equatable/equatable.dart';
import '../../../domain/entities/sms_session.dart';
import '../../../domain/entities/sms_log.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<SmsSession> sessions;
  const HistoryLoaded(this.sessions);
  @override
  List<Object?> get props => [sessions];
}

class HistoryDetailsLoaded extends HistoryState {
  final SmsSession session;
  final List<SmsLog> logs;
  const HistoryDetailsLoaded({required this.session, required this.logs});
  @override
  List<Object?> get props => [session, logs];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
