import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/history/data/models/sms_session.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';
import 'package:sender_sms/features/history/data/repos/sms_repository.dart';

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

class HistoryCubit extends Cubit<HistoryState> {
  final SmsRepository _smsRepository;

  HistoryCubit(this._smsRepository) : super(HistoryInitial());

  Future<void> load() async {
    emit(HistoryLoading());
    try {
      final sessions = await _smsRepository.getSessions();
      emit(HistoryLoaded(sessions));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> loadDetails(String sessionId) async {
    emit(HistoryLoading());
    try {
      final session = await _smsRepository.getSession(sessionId);
      final logs = await _smsRepository.getLogsBySession(sessionId);
      if (session == null) throw Exception('Session not found');
      emit(HistoryDetailsLoaded(session: session, logs: logs));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
