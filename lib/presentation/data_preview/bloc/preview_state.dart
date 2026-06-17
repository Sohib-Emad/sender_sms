import 'package:equatable/equatable.dart';
import '../../../domain/entities/student.dart';

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
