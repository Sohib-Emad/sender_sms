import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/history/data/models/sms_session.dart';
import 'package:sender_sms/features/history/data/repos/sms_repository.dart';
import 'package:sender_sms/features/import_excel/data/repos/students_repository.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int totalStudents;
  final int totalSent;
  final int totalFailed;
  final List<SmsSession> recentSessions;
  final SmsSession? lastSession;

  const HomeLoaded({
    required this.totalStudents,
    required this.totalSent,
    required this.totalFailed,
    required this.recentSessions,
    this.lastSession,
  });

  @override
  List<Object?> get props =>
      [totalStudents, totalSent, totalFailed, recentSessions, lastSession];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeCubit extends Cubit<HomeState> {
  final SmsRepository _smsRepository;
  final StudentsRepository _studentsRepository;

  HomeCubit(this._smsRepository, this._studentsRepository) : super(HomeInitial());

  Future<void> loadStats() async {
    if (state is HomeLoading) return;
    if (state is! HomeLoaded) emit(HomeLoading());
    try {
      final sessions = await _smsRepository.getSessions();
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
