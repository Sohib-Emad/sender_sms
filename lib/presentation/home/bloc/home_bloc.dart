import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../domain/usecases/get_sessions_usecase.dart';
import '../../../domain/repositories/students_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetSessionsUseCase _getSessionsUseCase;
  final StudentsRepository _studentsRepository;

  HomeBloc(this._getSessionsUseCase, this._studentsRepository)
      : super(HomeInitial()) {
    on<HomeLoadStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(
      HomeLoadStats event, Emitter<HomeState> emit) async {
    if (state is HomeLoading) return;
    if (state is! HomeLoaded) emit(HomeLoading());
    try {
      final sessions = await _getSessionsUseCase();
      final students = await _studentsRepository.getStudents();

      final totalSent = sessions.fold<int>(0, (s, e) => s + e.success);
      final totalFailed = sessions.fold<int>(0, (s, e) => s + e.failed);
      final recentSessions = sessions.take(3).toList();
      final lastSession = sessions.isNotEmpty ? sessions.first : null;

      emit(HomeLoaded(
        totalStudents: students.length,
        totalSent: totalSent,
        totalFailed: totalFailed,
        recentSessions: recentSessions,
        lastSession: lastSession,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
