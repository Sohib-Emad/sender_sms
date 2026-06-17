import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_settings.dart';

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
