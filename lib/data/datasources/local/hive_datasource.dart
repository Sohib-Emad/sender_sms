import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sender_sms/data/models/sms_log_model.dart';
import 'package:sender_sms/data/models/sms_session_model.dart';
import 'package:sender_sms/data/models/student_model.dart';
import 'package:sender_sms/data/models/template_model.dart';


class HiveDatasource {
  static const String studentsBox = 'students';
  static const String sessionsBox = 'sms_sessions';
  static const String logsBox = 'sms_logs';
  static const String templatesBox = 'templates';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(StudentAdapter());
    Hive.registerAdapter(SmsSessionAdapter());
    Hive.registerAdapter(SmsLogAdapter());
    Hive.registerAdapter(TemplateAdapter());

    // Open boxes
    await Hive.openBox<StudentModel>(studentsBox);
    await Hive.openBox<SmsSessionModel>(sessionsBox);
    await Hive.openBox<SmsLogModel>(logsBox);
    await Hive.openBox<TemplateModel>(templatesBox);
    await Hive.openBox(settingsBox);
  }

  // ─── Students ─────────────────────────────────────────────
  Box<StudentModel> get students => Hive.box<StudentModel>(studentsBox);

  Future<void> saveStudents(List<StudentModel> models) async {
    await students.clear();
    await students.addAll(models);
  }

  Future<void> addStudent(StudentModel model) async {
    await students.put(model.id, model);
  }

  Future<void> updateStudent(StudentModel model) async {
    await students.put(model.id, model);
  }

  Future<void> deleteStudent(String id) async {
    await students.delete(id);
  }

  List<StudentModel> getAllStudents() => students.values.toList();

  Future<void> clearStudents() async {
    await students.clear();
  }

  // ─── Sessions ─────────────────────────────────────────────
  Box<SmsSessionModel> get sessions =>
      Hive.box<SmsSessionModel>(sessionsBox);

  Future<void> saveSession(SmsSessionModel model) async {
    await sessions.put(model.id, model);
  }

  List<SmsSessionModel> getAllSessions() {
    final list = sessions.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  SmsSessionModel? getSession(String id) => sessions.get(id);

  // ─── Logs ─────────────────────────────────────────────────
  Box<SmsLogModel> get logs => Hive.box<SmsLogModel>(logsBox);

  Future<void> saveLog(SmsLogModel model) async {
    await logs.put(model.id, model);
  }

  Future<void> saveLogs(List<SmsLogModel> models) async {
    final map = {for (final m in models) m.id: m};
    await logs.putAll(map);
  }

  List<SmsLogModel> getLogsBySession(String sessionId) =>
      logs.values.where((l) => l.sessionId == sessionId).toList();

  List<SmsLogModel> getFailedLogs(String sessionId) => logs.values
      .where((l) => l.sessionId == sessionId && l.status == 'failed')
      .toList();

  // ─── Templates ─────────────────────────────────────────────
  Box<TemplateModel> get templates => Hive.box<TemplateModel>(templatesBox);

  Future<void> saveTemplate(TemplateModel model) async {
    await templates.put(model.id, model);
  }

  Future<void> deleteTemplate(String id) async {
    await templates.delete(id);
  }

  List<TemplateModel> getAllTemplates() => templates.values.toList();

  // ─── Settings ─────────────────────────────────────────────
  Box get settingsData => Hive.box(settingsBox);

  Map<dynamic, dynamic>? getSettings() =>
      settingsData.get('app_settings') as Map<dynamic, dynamic>?;

  Future<void> saveSettingsMap(Map<String, dynamic> map) async {
    await settingsData.put('app_settings', map);
  }
}
