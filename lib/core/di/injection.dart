import 'package:get_it/get_it.dart';
import '../../data/datasources/local/hive_datasource.dart';
import '../../data/datasources/sms/sms_service.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/sms_repository_impl.dart';
import '../../data/repositories/students_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/sms_repository.dart';
import '../../domain/repositories/students_repository.dart';
import '../../domain/usecases/export_report_usecase.dart';
import '../../domain/usecases/get_sessions_usecase.dart';
import '../../domain/usecases/import_excel_usecase.dart';
import '../../domain/usecases/send_sms_batch_usecase.dart';
import '../../presentation/home/bloc/home_bloc.dart';
import '../../presentation/import_excel/bloc/import_bloc.dart';
import '../../presentation/data_preview/bloc/preview_bloc.dart';
import '../../presentation/message_template/bloc/template_bloc.dart';
import '../../presentation/send_sms/bloc/send_bloc.dart';
import '../../presentation/history/bloc/history_bloc.dart';
import '../../presentation/settings/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Datasources ──────────────────────────────────────
  final hiveDatasource = HiveDatasource();
  sl.registerSingleton<HiveDatasource>(hiveDatasource);
  sl.registerLazySingleton<SmsService>(() => SmsService());

  // ── Repositories ─────────────────────────────────────
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
  sl.registerLazySingleton(() => ImportExcelUseCase());
  sl.registerLazySingleton(() => SendSmsBatchUseCase(sl(), sl()));
  sl.registerLazySingleton(() => GetSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionLogsUseCase(sl()));
  sl.registerLazySingleton(() => GetFailedLogsUseCase(sl()));
  sl.registerLazySingleton(() => ExportReportUseCase(sl()));

  // ── BLoCs ─────────────────────────────────────────────
  sl.registerLazySingleton(() => HomeBloc(sl(), sl()));
  sl.registerFactory(() => ImportBloc(sl()));
  sl.registerFactory(() => PreviewBloc(sl<StudentsRepository>()));
  sl.registerFactory(() => TemplateBloc(sl()));
  sl.registerSingleton(SendBloc(sl(), sl(), sl()));
  sl.registerFactory(() => HistoryBloc(sl(), sl()));
  sl.registerFactory(() => SettingsBloc(sl()));
}
