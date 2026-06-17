import 'package:equatable/equatable.dart';
import '../../../domain/entities/message_template.dart';

abstract class TemplateEvent extends Equatable {
  const TemplateEvent();
  @override
  List<Object?> get props => [];
}

class TemplateLoad extends TemplateEvent {}

class TemplateSave extends TemplateEvent {
  final MessageTemplate template;
  const TemplateSave(this.template);
  @override
  List<Object?> get props => [template];
}

class TemplateDelete extends TemplateEvent {
  final String id;
  const TemplateDelete(this.id);
  @override
  List<Object?> get props => [id];
}

class TemplateSelect extends TemplateEvent {
  final MessageTemplate template;
  const TemplateSelect(this.template);
  @override
  List<Object?> get props => [template];
}
