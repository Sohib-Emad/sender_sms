import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local/hive_datasource.dart';
import 'presentation/send_sms/bloc/send_bloc.dart';
import 'presentation/settings/bloc/settings_bloc.dart';
import 'presentation/settings/bloc/settings_event.dart';
import 'presentation/settings/bloc/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await HiveDatasource.init();

  // Setup DI
  await setupDependencies();

  runApp(const SenderSmsApp());
}

class SenderSmsApp extends StatelessWidget {
  const SenderSmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // SendBloc provided at app level so it persists across screens
        BlocProvider<SendBloc>(
          create: (_) => sl<SendBloc>(),
        ),
        // Settings at app level for theme
        BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(SettingsLoad()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final isDark = state is SettingsLoaded
              ? state.settings.isDarkMode
              : true;

          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

            // Routing
            routerConfig: AppRouter.router,

            // Localization (RTL Arabic)
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

            // Builder for RTL
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
