import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/message_template/data/models/message_template.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<List<MessageTemplate>> getTemplates();
  Future<void> saveTemplate(MessageTemplate template);
  Future<void> deleteTemplate(String id);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final HiveDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<AppSettings> getSettings() async {
    final map = _datasource.getSettings();
    if (map == null) return const AppSettings();
    return AppSettings.fromMap(map);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _datasource.saveSettingsMap(settings.toMap());
  }

  @override
  Future<List<MessageTemplate>> getTemplates() async {
    return _datasource.getAllTemplates();
  }

  @override
  Future<void> saveTemplate(MessageTemplate template) async {
    await _datasource.saveTemplate(template);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _datasource.deleteTemplate(id);
  }
}
