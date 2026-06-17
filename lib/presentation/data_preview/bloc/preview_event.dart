import 'package:equatable/equatable.dart';
import '../../../domain/entities/student.dart';

abstract class PreviewEvent extends Equatable {
  const PreviewEvent();
  @override
  List<Object?> get props => [];
}

class PreviewLoadStudents extends PreviewEvent {
  final List<Student> students;
  const PreviewLoadStudents(this.students);
  @override
  List<Object?> get props => [students];
}

class PreviewSearchChanged extends PreviewEvent {
  final String query;
  const PreviewSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class PreviewDeleteStudent extends PreviewEvent {
  final String studentId;
  const PreviewDeleteStudent(this.studentId);
  @override
  List<Object?> get props => [studentId];
}

class PreviewUpdateStudent extends PreviewEvent {
  final Student student;
  const PreviewUpdateStudent(this.student);
  @override
  List<Object?> get props => [student];
}

class PreviewAddStudent extends PreviewEvent {
  final Student student;
  const PreviewAddStudent(this.student);
  @override
  List<Object?> get props => [student];
}
