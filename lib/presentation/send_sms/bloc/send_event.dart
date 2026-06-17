import 'package:equatable/equatable.dart';
import '../../../domain/entities/student.dart';

abstract class SendEvent extends Equatable {
  const SendEvent();
  @override
  List<Object?> get props => [];
}

class SendStartBatch extends SendEvent {
  final List<Student> students;
  final String template;

  const SendStartBatch({
    required this.students,
    required this.template,
  });

  @override
  List<Object?> get props => [students, template];
}

class SendPause extends SendEvent {}

class SendResume extends SendEvent {}

class SendCancel extends SendEvent {}

class SendReset extends SendEvent {}
