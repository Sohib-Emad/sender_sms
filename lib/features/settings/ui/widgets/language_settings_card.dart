import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class LanguageSettingsCard extends StatelessWidget {
  final AppSettings settings;
  const LanguageSettingsCard({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  ScreenStrings.language,
                  style: Theme.of(context).textTheme.titleMedium,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.language_rounded, color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _LanguageButton(
                    label: ScreenStrings.english,
                    isSelected: settings.language == 'en',
                    onTap: () => context.read<SettingsCubit>().save(settings.copyWith(language: 'en')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LanguageButton(
                    label: ScreenStrings.arabic,
                    isSelected: settings.language == 'ar',
                    onTap: () => context.read<SettingsCubit>().save(settings.copyWith(language: 'ar')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
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
          color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary, width: isSelected ? 0 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
