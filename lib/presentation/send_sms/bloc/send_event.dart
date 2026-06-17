import 'package:equatable/equatable.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/app_settings.dart';

abstract class SendEvent extends Equatable {
  const SendEvent();
  @override
  List<Object?> get props => [];
}

class SendStartBatch extends SendEvent {
  final List<Student> students;
  final String template;
  final AppSettings settings;

  const SendStartBatch({
    required this.students,
    required this.template,
    required this.settings,
  });

  @override
  List<Object?> get props => [students, template, settings];
}

class SendPause extends SendEvent {}

class SendResume extends SendEvent {}

class SendCancel extends SendEvent {}

class SendReset extends SendEvent {}
