import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/hive_datasource.dart';
import 'core/services/notification_service.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/logic/auth_state.dart';
import 'features/notifications/logic/notifications_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge mode for Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await HiveDatasource.init();
  await setupDependencies();
  await sl<NotificationService>().init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) => sl<NotificationsCubit>(),
        ),
      ],
      child: const SenderSmsApp(),
    ),
  );
}

class SenderSmsApp extends StatelessWidget {
  const SenderSmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Status bar
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        // Navigation bar - TRANSPARENT
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        locale: const Locale('ar'),
        builder: (context, child) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                AppRouter.router.go(AppRoutes.login);
              } else if (state is AuthBlocked) {
                context.read<AuthCubit>().signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(state.message, textDirection: TextDirection.rtl),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
