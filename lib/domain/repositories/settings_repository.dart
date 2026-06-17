import '../../domain/entities/app_settings.dart';
import '../../domain/entities/message_template.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);

  Future<List<MessageTemplate>> getTemplates();
  Future<void> saveTemplate(MessageTemplate template);
  Future<void> deleteTemplate(String id);
}
