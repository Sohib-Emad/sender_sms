import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/settings/data/repos/settings_repository.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  const SettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsSaving extends SettingsState {
  final AppSettings settings;
  const SettingsSaving(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(SettingsInitial());

  Future<void> load() async {
    final settings = await _settingsRepository.getSettings();
    emit(SettingsLoaded(settings));
  }

  Future<void> save(AppSettings settings) async {
    emit(SettingsSaving(settings));
    await _settingsRepository.saveSettings(settings);
    emit(SettingsLoaded(settings));
  }
}
