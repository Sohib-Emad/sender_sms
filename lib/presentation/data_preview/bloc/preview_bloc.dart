import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/domain/repositories/students_repository.dart';
import 'preview_event.dart';
import 'preview_state.dart';
import '../../../domain/entities/student.dart';

class PreviewBloc extends Bloc<PreviewEvent, PreviewState> {
// not saving to Hive until send

  PreviewBloc(StudentsRepository studentsRepository) : super(PreviewInitial()) {
    on<PreviewLoadStudents>(_onLoad);
    on<PreviewSearchChanged>(_onSearch);
    on<PreviewDeleteStudent>(_onDelete);
    on<PreviewUpdateStudent>(_onUpdate);
    on<PreviewAddStudent>(_onAdd);
  }

  List<Student> _allStudents = [];

  void _onLoad(PreviewLoadStudents event, Emitter<PreviewState> emit) {
    _allStudents = event.students;
    emit(PreviewLoaded(
      allStudents: _allStudents,
      filteredStudents: _allStudents,
    ));
  }

  void _onSearch(PreviewSearchChanged event, Emitter<PreviewState> emit) {
    if (state is PreviewLoaded) {
      final query = event.query.toLowerCase();
      final filtered = query.isEmpty
          ? _allStudents
          : _allStudents
              .where((s) =>
                  s.name.toLowerCase().contains(query) ||
                  s.phone.contains(query) ||
                  s.degree.contains(query))
              .toList();

      emit(PreviewLoaded(
        allStudents: _allStudents,
        filteredStudents: filtered,
        searchQuery: event.query,
      ));
    }
  }

  void _onDelete(PreviewDeleteStudent event, Emitter<PreviewState> emit) {
    _allStudents = _allStudents
        .where((s) => s.id != event.studentId)
        .toList();
    final current = state as PreviewLoaded;
    final filtered = current.searchQuery.isEmpty
        ? _allStudents
        : _allStudents
            .where((s) =>
                s.name.toLowerCase().contains(current.searchQuery.toLowerCase()) ||
                s.phone.contains(current.searchQuery))
            .toList();
    emit(PreviewLoaded(
      allStudents: _allStudents,
      filteredStudents: filtered,
      searchQuery: current.searchQuery,
    ));
  }

  void _onUpdate(PreviewUpdateStudent event, Emitter<PreviewState> emit) {
    _allStudents = _allStudents
        .map((s) => s.id == event.student.id ? event.student : s)
        .toList();
    final current = state as PreviewLoaded;
    emit(PreviewLoaded(
      allStudents: _allStudents,
      filteredStudents: _allStudents,
      searchQuery: current.searchQuery,
    ));
  }

  void _onAdd(PreviewAddStudent event, Emitter<PreviewState> emit) {
    _allStudents = [event.student, ..._allStudents];
    final current = state is PreviewLoaded ? (state as PreviewLoaded) : null;
    emit(PreviewLoaded(
      allStudents: _allStudents,
      filteredStudents: _allStudents,
      searchQuery: current?.searchQuery ?? '',
    ));
  }
}
