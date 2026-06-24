import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/features/auth/ui/login_page.dart';
import 'package:sender_sms/features/data_preview/logic/preview_cubit.dart';
import 'package:sender_sms/features/data_preview/ui/data_preview_page.dart';
import 'package:sender_sms/features/failed_messages/ui/failed_messages_page.dart';
import 'package:sender_sms/features/history/logic/history_cubit.dart';
import 'package:sender_sms/features/history/ui/history_page.dart';
import 'package:sender_sms/features/home/logic/home_cubit.dart';
import 'package:sender_sms/features/home/ui/main_layout_page.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/import_excel/logic/import_cubit.dart';
import 'package:sender_sms/features/import_excel/ui/import_excel_page.dart';
import 'package:sender_sms/features/manual_sms/ui/manual_sms_page.dart';
import 'package:sender_sms/features/message_template/logic/template_cubit.dart';
import 'package:sender_sms/features/message_template/ui/message_template_page.dart';
import 'package:sender_sms/features/results/ui/results_page.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';
import 'package:sender_sms/features/send_sms/ui/send_sms_page.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/features/settings/ui/settings_page.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'package:sender_sms/features/admin_dashboard/ui/admin_dashboard_page.dart';
import 'app_routes.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      if (!isLoggedIn && !isOnLogin) return AppRoutes.login;
      if (isLoggedIn && isOnLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (c, s) => const LoginPage()),
      GoRoute(
        path: AppRoutes.home,
        builder: (c, s) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<HomeCubit>()..loadStats()),
            BlocProvider(create: (_) => sl<HistoryCubit>()..load()),
            BlocProvider(create: (_) => sl<SettingsCubit>()..load()),
          ],
          child: const MainLayoutPage(),
        ),
      ),
      GoRoute(path: AppRoutes.importExcel, builder: (c, s) => BlocProvider(
        create: (_) => sl<ImportCubit>(),
        child: const ImportExcelPage(),
      )),
      GoRoute(path: AppRoutes.dataPreview, builder: (c, s) => BlocProvider(
        create: (_) => sl<PreviewCubit>()..load(s.extra as List<Student>),
        child: const DataPreviewPage(),
      )),
      GoRoute(path: AppRoutes.messageTemplate, builder: (c, s) => BlocProvider(
        create: (_) => sl<TemplateCubit>()..load(),
        child: MessageTemplatePage(students: s.extra as List<Student>),
      )),
      GoRoute(path: AppRoutes.sendSms, builder: (c, s) {
        final args = s.extra as Map<String, dynamic>;
        sl<SendCubit>().reset();
        return SendSmsPage(
          students: args['students'] as List<Student>,
          template: args['template'] as String,
        );
      }),
      GoRoute(path: AppRoutes.results, builder: (c, s) {
        final args = s.extra as Map<String, dynamic>;
        return ResultsPage(
          sessionId: args['sessionId'] as String,
          total: args['total'] as int,
          sent: args['sent'] as int,
          failed: args['failed'] as int,
        );
      }),
      GoRoute(path: AppRoutes.failedMessages, builder: (c, s) =>
          FailedMessagesPage(sessionId: s.extra as String)),
      GoRoute(path: AppRoutes.history, builder: (c, s) => BlocProvider(
        create: (_) => sl<HistoryCubit>()..load(),
        child: const HistoryPage(),
      )),
      GoRoute(path: AppRoutes.settings, builder: (c, s) => BlocProvider(
        create: (_) => sl<SettingsCubit>()..load(),
        child: const SettingsPage(),
      )),
      GoRoute(path: AppRoutes.manualSms, builder: (c, s) => const ManualSmsPage()),
      GoRoute(path: AppRoutes.adminDashboard, builder: (c, s) => BlocProvider(
        create: (_) => sl<AdminDashboardCubit>(),
        child: const AdminDashboardPage(),
      )),
    ],
  );
}
