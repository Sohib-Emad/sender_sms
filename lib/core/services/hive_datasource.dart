import 'package:hive_flutter/hive_flutter.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/history/data/models/sms_session.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';
import 'package:sender_sms/features/message_template/data/models/message_template.dart';
import 'package:sender_sms/features/notifications/data/models/app_notification.dart';

class HiveDatasource {
  static const String studentsBox = 'students';
  static const String sessionsBox = 'sms_sessions';
  static const String logsBox = 'sms_logs';
  static const String templatesBox = 'templates';
  static const String settingsBox = 'settings';
  static const String notificationsBox = 'app_notifications';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(StudentAdapter());
    Hive.registerAdapter(SmsSessionAdapter());
    Hive.registerAdapter(SmsLogAdapter());
    Hive.registerAdapter(TemplateAdapter());
    Hive.registerAdapter(AppNotificationAdapter());

    await Hive.openBox<Student>(studentsBox);
    await Hive.openBox<SmsSession>(sessionsBox);
    await Hive.openBox<SmsLog>(logsBox);
    await Hive.openBox<MessageTemplate>(templatesBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox<AppNotification>(notificationsBox);
  }

  Box<Student> get students => Hive.box<Student>(studentsBox);
  Box<SmsSession> get sessions => Hive.box<SmsSession>(sessionsBox);
  Box<SmsLog> get logs => Hive.box<SmsLog>(logsBox);
  Box<MessageTemplate> get templates => Hive.box<MessageTemplate>(templatesBox);
  Box get settingsData => Hive.box(settingsBox);
  Box<AppNotification> get notifications => Hive.box<AppNotification>(notificationsBox);

  Future<void> saveStudents(List<Student> models) async {
    await students.clear();
    await students.addAll(models);
  }

  Future<void> addStudent(Student m) => students.put(m.id, m);
  Future<void> updateStudent(Student m) => students.put(m.id, m);
  Future<void> deleteStudent(String id) => students.delete(id);
  List<Student> getAllStudents() => students.values.toList();
  Future<void> clearStudents() => students.clear();

  Future<void> saveSession(SmsSession m) => sessions.put(m.id, m);
  List<SmsSession> getAllSessions() =>
      sessions.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  SmsSession? getSession(String id) => sessions.get(id);

  Future<void> saveLog(SmsLog m) => logs.put(m.id, m);
  Future<void> saveLogs(List<SmsLog> ms) =>
      logs.putAll({for (final m in ms) m.id: m});
  List<SmsLog> getLogsBySession(String sId) =>
      logs.values.where((l) => l.sessionId == sId).toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  List<SmsLog> getFailedLogs(String sId) =>
      logs.values.where((l) => l.sessionId == sId && l.status == 'failed').toList();

  Future<void> saveTemplate(MessageTemplate m) => templates.put(m.id, m);
  Future<void> deleteTemplate(String id) => templates.delete(id);
  List<MessageTemplate> getAllTemplates() => templates.values.toList();

  Map<dynamic, dynamic>? getSettings() =>
      settingsData.get('app_settings') as Map<dynamic, dynamic>?;
  Future<void> saveSettingsMap(Map<String, dynamic> map) =>
      settingsData.put('app_settings', map);

  Future<void> saveNotification(AppNotification m) => notifications.put(m.id, m);
  List<AppNotification> getAllNotifications() =>
      notifications.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  Future<void> deleteNotification(String id) => notifications.delete(id);
  Future<void> clearNotifications() => notifications.clear();
}
