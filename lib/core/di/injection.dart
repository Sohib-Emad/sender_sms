import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:sender_sms/core/services/firebase_reporting_service.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/core/services/notification_service.dart';
import 'package:sender_sms/features/notifications/logic/notifications_cubit.dart';
import 'package:sender_sms/features/auth/data/repos/auth_repository.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'package:sender_sms/features/import_excel/data/repos/students_repository.dart';
import 'package:sender_sms/features/history/data/repos/sms_repository.dart';
import 'package:sender_sms/features/settings/data/repos/settings_repository.dart';
import 'package:sender_sms/features/send_sms/logic/send_sms_batch_usecase.dart';
import 'package:sender_sms/features/home/logic/home_cubit.dart';
import 'package:sender_sms/features/import_excel/logic/import_cubit.dart';
import 'package:sender_sms/features/data_preview/logic/preview_cubit.dart';
import 'package:sender_sms/features/message_template/logic/template_cubit.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';
import 'package:sender_sms/features/history/logic/history_cubit.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/features/failed_messages/logic/failed_cubit.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Firebase ──────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // ── Datasources ───────────────────────────────────────
  final hiveDatasource = HiveDatasource();
  sl.registerSingleton<HiveDatasource>(hiveDatasource);
  sl.registerLazySingleton<SmsService>(() => SmsService());
  sl.registerLazySingleton(() => FirebaseReportingService(sl(), sl()));
  sl.registerLazySingleton<NotificationService>(() => NotificationService(sl()));

  // ── Repositories ──────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<StudentsRepository>(
    () => StudentsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SmsRepository>(
    () => SmsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // ── Use Cases ─────────────────────────────────────────
  sl.registerLazySingleton(() => SendSmsBatchUseCase(sl(), sl(), sl()));

  // ── Cubits ────────────────────────────────────────────
  sl.registerLazySingleton(() => AuthCubit(sl()));
  sl.registerLazySingleton(() => HomeCubit(sl(), sl()));
  sl.registerFactory(() => ImportCubit());
  sl.registerFactory(() => PreviewCubit());
  sl.registerFactory(() => TemplateCubit(sl()));
  sl.registerSingleton(SendCubit(sl(), sl(), sl()));
  sl.registerFactory(() => HistoryCubit(sl()));
  sl.registerFactory(() => SettingsCubit(sl()));
  sl.registerFactory(() => FailedCubit(sl(), sl(), sl()));
  sl.registerFactory(() => AdminDashboardCubit(sl()));
  sl.registerSingleton<NotificationsCubit>(NotificationsCubit(sl()));
}
