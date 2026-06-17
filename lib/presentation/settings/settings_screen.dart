import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/app_settings.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/settings_event.dart';
import 'bloc/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final settings = state is SettingsLoaded
              ? state.settings
              : const AppSettings();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(title: AppStrings.messageSettings),
              const SizedBox(height: 12),

              // Delay between messages
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${settings.delaySeconds} ${AppStrings.seconds}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Row(
                            children: [
                              Text(AppStrings.delayBetween,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  textDirection: TextDirection.rtl),
                              const SizedBox(width: 8),
                              const Icon(Icons.timer_rounded,
                                  color: AppColors.primary, size: 20),
                            ],
                          ),
                        ],
                      ),
                      Slider(
                        value: settings.delaySeconds.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: '${settings.delaySeconds}s',
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(SettingsSave(
                                settings.copyWith(
                                    delaySeconds: value.toInt()),
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // SIM card selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(AppStrings.simCard,
                              style: Theme.of(context).textTheme.titleMedium,
                              textDirection: TextDirection.rtl),
                          const SizedBox(width: 8),
                          const Icon(Icons.sim_card_rounded,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SimButton(
                              label: AppStrings.sim2,
                              isSelected: settings.simSlot == 1,
                              onTap: () {
                                context.read<SettingsBloc>().add(
                                      SettingsSave(
                                          settings.copyWith(simSlot: 1)),
                                    );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SimButton(
                              label: AppStrings.sim1,
                              isSelected: settings.simSlot == 0,
                              onTap: () {
                                context.read<SettingsBloc>().add(
                                      SettingsSave(
                                          settings.copyWith(simSlot: 0)),
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Daily limit
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Switch(
                            value: settings.dailyLimit > 0,
                            onChanged: (v) {
                              context.read<SettingsBloc>().add(
                                    SettingsSave(settings.copyWith(
                                        dailyLimit: v ? 100 : 0)),
                                  );
                            },
                          ),
                          Row(
                            children: [
                              Text(AppStrings.dailyLimit,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  textDirection: TextDirection.rtl),
                              const SizedBox(width: 8),
                              const Icon(Icons.block_rounded,
                                  color: AppColors.primary, size: 20),
                            ],
                          ),
                        ],
                      ),
                      if (settings.dailyLimit > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${settings.dailyLimit} رسالة/يوم',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold)),
                            Text('الحد اليومي',
                                style: Theme.of(context).textTheme.bodySmall,
                                textDirection: TextDirection.rtl),
                          ],
                        ),
                        Slider(
                          value: settings.dailyLimit.toDouble(),
                          min: 10,
                          max: 500,
                          divisions: 49,
                          label: '${settings.dailyLimit}',
                          onChanged: (v) {
                            context.read<SettingsBloc>().add(
                                  SettingsSave(settings.copyWith(
                                      dailyLimit: v.toInt())),
                                );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: AppStrings.appSettings),
              const SizedBox(height: 12),

              // Dark mode
              Card(
                child: SwitchListTile(
                  value: settings.isDarkMode,
                  onChanged: (v) {
                    context.read<SettingsBloc>().add(
                          SettingsSave(settings.copyWith(isDarkMode: v)),
                        );
                  },
                  title: Text(
                    AppStrings.darkMode,
                    textDirection: TextDirection.rtl,
                  ),
                  secondary: Icon(
                    settings.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                ),
              ),

              const SizedBox(height: 12),

              // Language
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(AppStrings.language,
                              style: Theme.of(context).textTheme.titleMedium,
                              textDirection: TextDirection.rtl),
                          const SizedBox(width: 8),
                          const Icon(Icons.language_rounded,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _LanguageButton(
                              label: AppStrings.english,
                              flag: '🇺🇸',
                              isSelected: settings.language == 'en',
                              onTap: () => context.read<SettingsBloc>().add(
                                    SettingsSave(
                                        settings.copyWith(language: 'en')),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LanguageButton(
                              label: AppStrings.arabic,
                              flag: '🇸🇦',
                              isSelected: settings.language == 'ar',
                              onTap: () => context.read<SettingsBloc>().add(
                                    SettingsSave(
                                        settings.copyWith(language: 'ar')),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _SectionHeader(title: AppStrings.about),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _InfoRow(label: '1.0.0', title: AppStrings.version),
                      const Divider(height: 20),
                      _InfoRow(
                          label: 'Flutter + BLoC + Hive',
                          title: 'التقنية المستخدمة'),
                      const Divider(height: 20),
                      _InfoRow(label: '21+', title: 'الحد الأدنى لـ Android'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(width: 8),
        Container(
          height: 2,
          width: 30,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

class _SimButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SimButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String label;

  const _InfoRow({required this.title, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
