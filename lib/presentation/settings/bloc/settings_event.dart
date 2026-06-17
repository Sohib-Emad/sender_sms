import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsLoad extends SettingsEvent {}

class SettingsSave extends SettingsEvent {
  final AppSettings settings;
  const SettingsSave(this.settings);
  @override
  List<Object?> get props => [settings];
}
