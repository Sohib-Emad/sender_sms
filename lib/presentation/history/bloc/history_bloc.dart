import 'package:flutter_bloc/flutter_bloc.dart';
import 'history_event.dart';
import 'history_state.dart';
import '../../../domain/usecases/get_sessions_usecase.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetSessionsUseCase _getSessionsUseCase;
  final GetSessionLogsUseCase _getLogsUseCase;

  HistoryBloc(this._getSessionsUseCase, this._getLogsUseCase)
      : super(HistoryInitial()) {
    on<HistoryLoad>(_onLoad);
    on<HistoryLoadDetails>(_onLoadDetails);
  }

  Future<void> _onLoad(HistoryLoad event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final sessions = await _getSessionsUseCase();
      emit(HistoryLoaded(sessions));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onLoadDetails(
      HistoryLoadDetails event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final sessions = await _getSessionsUseCase();
      final session = sessions.firstWhere((s) => s.id == event.sessionId);
      final logs = await _getLogsUseCase(event.sessionId);
      emit(HistoryDetailsLoaded(session: session, logs: logs));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
