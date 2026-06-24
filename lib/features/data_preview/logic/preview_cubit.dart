import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';

abstract class PreviewState extends Equatable {
  const PreviewState();
  @override
  List<Object?> get props => [];
}

class PreviewInitial extends PreviewState {}

class PreviewLoaded extends PreviewState {
  final List<Student> allStudents;
  final List<Student> filteredStudents;
  final String searchQuery;

  const PreviewLoaded({
    required this.allStudents,
    required this.filteredStudents,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allStudents, filteredStudents, searchQuery];
}

class PreviewCubit extends Cubit<PreviewState> {
  PreviewCubit() : super(PreviewInitial());

  List<Student> _allStudents = [];

  void load(List<Student> students) {
    _allStudents = students;
    emit(PreviewLoaded(allStudents: _allStudents, filteredStudents: _allStudents));
  }

  void search(String query) {
    final cur = state;
    if (cur is PreviewLoaded) {
      final q = query.toLowerCase();
      final filtered = q.isEmpty
          ? _allStudents
          : _allStudents
              .where((s) =>
                  s.name.toLowerCase().contains(q) ||
                  s.phone.contains(q) ||
                  s.degree.contains(q))
              .toList();
      emit(PreviewLoaded(allStudents: _allStudents, filteredStudents: filtered, searchQuery: query));
    }
  }

  void delete(String id) {
    final cur = state;
    if (cur is PreviewLoaded) {
      _allStudents = _allStudents.where((s) => s.id != id).toList();
      search(cur.searchQuery);
    }
  }

  void updateStudent(Student student) {
    final cur = state;
    if (cur is PreviewLoaded) {
      _allStudents = _allStudents.map((s) => s.id == student.id ? student : s).toList();
      search(cur.searchQuery);
    }
  }

  void addStudent(Student student) {
    final cur = state;
    final q = cur is PreviewLoaded ? cur.searchQuery : '';
    _allStudents = [student, ..._allStudents];
    search(q);
  }
}
