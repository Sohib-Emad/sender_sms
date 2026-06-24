import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/message_template/data/models/message_template.dart';
import 'package:sender_sms/features/settings/data/repos/settings_repository.dart';

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

class TemplateError extends TemplateState {
  final String message;
  const TemplateError(this.message);
  @override
  List<Object?> get props => [message];
}

class TemplateCubit extends Cubit<TemplateState> {
  final SettingsRepository _settingsRepository;

  TemplateCubit(this._settingsRepository) : super(TemplateInitial());

  Future<void> load() async {
    try {
      final templates = await _settingsRepository.getTemplates();
      emit(TemplateLoaded(templates: templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> save(MessageTemplate template) async {
    emit(TemplateSaving());
    try {
      await _settingsRepository.saveTemplate(template);
      final templates = await _settingsRepository.getTemplates();
      emit(TemplateLoaded(templates: templates, selectedTemplate: template));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _settingsRepository.deleteTemplate(id);
      final templates = await _settingsRepository.getTemplates();
      emit(TemplateLoaded(templates: templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  void select(MessageTemplate template) {
    final cur = state;
    if (cur is TemplateLoaded) {
      emit(TemplateLoaded(templates: cur.templates, selectedTemplate: template));
    }
  }
}
