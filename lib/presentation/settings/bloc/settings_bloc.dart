import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../../domain/repositories/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository) : super(SettingsInitial()) {
    on<SettingsLoad>(_onLoad);
    on<SettingsSave>(_onSave);
  }

  Future<void> _onLoad(SettingsLoad event, Emitter<SettingsState> emit) async {
    final settings = await _settingsRepository.getSettings();
    emit(SettingsLoaded(settings));
  }

  Future<void> _onSave(SettingsSave event, Emitter<SettingsState> emit) async {
    emit(SettingsSaving(event.settings));
    await _settingsRepository.saveSettings(event.settings);
    emit(SettingsLoaded(event.settings));
  }
}
