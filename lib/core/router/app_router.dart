import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/presentation/data_preview/bloc/preview_event.dart';
import 'package:sender_sms/presentation/history/bloc/history_event.dart';
import 'package:sender_sms/presentation/home/bloc/home_event.dart';
import 'package:sender_sms/presentation/message_template/bloc/template_event.dart';
import 'package:sender_sms/presentation/settings/bloc/settings_event.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/import_excel/import_excel_screen.dart';
import '../../presentation/data_preview/data_preview_screen.dart';
import '../../presentation/message_template/message_template_screen.dart';
import '../../presentation/send_sms/send_sms_screen.dart';
import '../../presentation/results/results_screen.dart';
import '../../presentation/failed_messages/failed_messages_screen.dart';
import '../../presentation/history/history_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/manual_sms/manual_sms_screen.dart';
import '../../presentation/home/bloc/home_bloc.dart';
import '../../presentation/import_excel/bloc/import_bloc.dart';
import '../../presentation/data_preview/bloc/preview_bloc.dart';
import '../../presentation/message_template/bloc/template_bloc.dart';
import '../../presentation/history/bloc/history_bloc.dart';
import '../../presentation/settings/bloc/settings_bloc.dart';
import '../../domain/entities/student.dart';
import '../di/injection.dart';

class AppRouter {
  static const String home = '/';
  static const String importExcel = '/import';
  static const String dataPreview = '/preview';
  static const String messageTemplate = '/template';
  static const String sendSms = '/send';
  static const String results = '/results';
  static const String failedMessages = '/failed';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String manualSms = '/manual-sms';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<HomeBloc>()..add(HomeLoadStats()),
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: importExcel,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ImportBloc>(),
          child: const ImportExcelScreen(),
        ),
      ),
      GoRoute(
        path: dataPreview,
        builder: (context, state) {
          final students = state.extra as List<Student>;
          return BlocProvider(
            create: (_) => sl<PreviewBloc>()
              ..add(PreviewLoadStudents(students)),
            child: const DataPreviewScreen(),
          );
        },
      ),
      GoRoute(
        path: messageTemplate,
        builder: (context, state) {
          final students = state.extra as List<Student>;
          return BlocProvider(
            create: (_) => sl<TemplateBloc>()..add(TemplateLoad()),
            child: MessageTemplateScreen(students: students),
          );
        },
      ),
      GoRoute(
        path: sendSms,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return SendSmsScreen(
            students: args['students'] as List<Student>,
            template: args['template'] as String,
          );
        },
      ),
      GoRoute(
        path: results,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ResultsScreen(
            sessionId: args['sessionId'] as String,
            total: args['total'] as int,
            sent: args['sent'] as int,
            failed: args['failed'] as int,
          );
        },
      ),
      GoRoute(
        path: failedMessages,
        builder: (context, state) {
          final sessionId = state.extra as String;
          return FailedMessagesScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: history,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<HistoryBloc>()..add(HistoryLoad()),
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SettingsBloc>()..add(SettingsLoad()),
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: manualSms,
        builder: (context, state) => const ManualSmsScreen(),
      ),
    ],
  );
}
