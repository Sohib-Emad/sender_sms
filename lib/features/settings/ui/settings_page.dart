import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';
import 'widgets/section_header.dart';
import 'widgets/delay_settings_card.dart';
import 'widgets/sim_settings_card.dart';
import 'widgets/daily_limit_card.dart';
import 'widgets/language_settings_card.dart';
import 'widgets/default_sms_app_card.dart';
import 'widgets/profile_card.dart';
import 'widgets/logout_button.dart';

class SettingsPage extends StatelessWidget {
  final bool isTab;
  const SettingsPage({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ScreenStrings.settingsTitle),
        automaticallyImplyLeading: !isTab,
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.pop(),
              ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settings = state is SettingsLoaded ? state.settings : const AppSettings();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const ProfileCard(),
              const SizedBox(height: 20),
              const SectionHeader(title: ScreenStrings.messageSettings),
              const SizedBox(height: 12),
              DelaySettingsCard(settings: settings),
              const SizedBox(height: 12),
              SimSettingsCard(settings: settings),
              const SizedBox(height: 12),
              DailyLimitCard(settings: settings),
              const SizedBox(height: 24),
              const SectionHeader(title: ScreenStrings.appSettings),
              const SizedBox(height: 12),
              const DefaultSmsAppCard(),
              const SizedBox(height: 12),
              LanguageSettingsCard(settings: settings),
              const SizedBox(height: 24),
              const LogoutButton(),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
