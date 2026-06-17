import 'package:flutter_bloc/flutter_bloc.dart';
import 'template_event.dart';
import 'template_state.dart';
import '../../../domain/repositories/settings_repository.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final SettingsRepository _settingsRepository;

  TemplateBloc(this._settingsRepository) : super(TemplateInitial()) {
    on<TemplateLoad>(_onLoad);
    on<TemplateSave>(_onSave);
    on<TemplateDelete>(_onDelete);
    on<TemplateSelect>(_onSelect);
  }

  Future<void> _onLoad(TemplateLoad event, Emitter<TemplateState> emit) async {
    try {
      final templates = await _settingsRepository.getTemplates();
      emit(TemplateLoaded(templates: templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> _onSave(
      TemplateSave event, Emitter<TemplateState> emit) async {
    emit(TemplateSaving());
    try {
      await _settingsRepository.saveTemplate(event.template);
      final templates = await _settingsRepository.getTemplates();
      emit(TemplateLoaded(
        templates: templates,
        selectedTemplate: event.template,
      ));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> _onDelete(
      TemplateDelete event, Emitter<TemplateState> emit) async {
    try {
      await _settingsRepository.deleteTemplate(event.id);
      final templates = await _settingsRepository.getTemplates();
      emit(TemplateLoaded(templates: templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  void _onSelect(TemplateSelect event, Emitter<TemplateState> emit) {
    if (state is TemplateLoaded) {
      final current = state as TemplateLoaded;
      emit(TemplateLoaded(
        templates: current.templates,
        selectedTemplate: event.template,
      ));
    }
  }
}
