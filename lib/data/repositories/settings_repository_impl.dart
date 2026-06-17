import '../../domain/entities/app_settings.dart';
import '../../domain/entities/message_template.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/template_model.dart';

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
    return _datasource.getAllTemplates().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveTemplate(MessageTemplate template) async {
    await _datasource.saveTemplate(TemplateModel.fromEntity(template));
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _datasource.deleteTemplate(id);
  }
}
