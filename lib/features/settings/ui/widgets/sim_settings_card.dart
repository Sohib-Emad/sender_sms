import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class SimSettingsCard extends StatelessWidget {
  final AppSettings settings;
  const SimSettingsCard({super.key, required this.settings});

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
                  ScreenStrings.simCard,
                  style: Theme.of(context).textTheme.titleMedium,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.sim_card_rounded, color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SimButton(
                    label: ScreenStrings.sim2,
                    isSelected: settings.simSlot == 1,
                    onTap: () => context.read<SettingsCubit>().save(settings.copyWith(simSlot: 1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SimButton(
                    label: ScreenStrings.sim1,
                    isSelected: settings.simSlot == 0,
                    onTap: () => context.read<SettingsCubit>().save(settings.copyWith(simSlot: 0)),
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
          color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary, width: isSelected ? 0 : 1),
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
