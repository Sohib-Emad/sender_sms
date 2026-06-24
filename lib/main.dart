import 'package:firebase_core/firebase_core.dart';
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
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/logic/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveDatasource.init();
  await setupDependencies();

  runApp(
    BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: const SenderSmsApp(),
    ),
  );
}

class SenderSmsApp extends StatelessWidget {
  const SenderSmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
                  content: Text(state.message, textDirection: TextDirection.rtl),
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
    );
  }
}
