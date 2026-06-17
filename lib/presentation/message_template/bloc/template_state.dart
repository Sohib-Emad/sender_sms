import 'package:equatable/equatable.dart';
import '../../../domain/entities/message_template.dart';

abstract class TemplateState extends Equatable {
  const TemplateState();
  @override
  List<Object?> get props => [];
}

class TemplateInitial extends TemplateState {}

class TemplateLoaded extends TemplateState {
  final List<MessageTemplate> templates;
  final MessageTemplate? selectedTemplate;

  const TemplateLoaded({required this.templates, this.selectedTemplate});

  @override
  List<Object?> get props => [templates, selectedTemplate];
}

class TemplateSaving extends TemplateState {}

class TemplateSaved extends TemplateState {}

class TemplateError extends TemplateState {
  final String message;
  const TemplateError(this.message);
  @override
  List<Object?> get props => [message];
}
