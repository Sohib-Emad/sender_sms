import 'package:equatable/equatable.dart';
import '../../../domain/entities/student.dart';

abstract class ImportState extends Equatable {
  const ImportState();
  @override
  List<Object?> get props => [];
}

class ImportInitial extends ImportState {}

class ImportLoading extends ImportState {}

class ImportSuccess extends ImportState {
  final List<Student> students;
  final String filePath;
  final String fileName;

  const ImportSuccess({
    required this.students,
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object?> get props => [students, filePath, fileName];
}

class ImportError extends ImportState {
  final String message;
  const ImportError(this.message);
  @override
  List<Object?> get props => [message];
}
