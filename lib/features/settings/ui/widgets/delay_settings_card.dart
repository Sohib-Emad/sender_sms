import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class DelaySettingsCard extends StatelessWidget {
  final AppSettings settings;
  const DelaySettingsCard({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${settings.delaySeconds} ${ScreenStrings.seconds}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    Text(
                      ScreenStrings.delayBetween,
                      style: Theme.of(context).textTheme.titleMedium,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.timer_rounded, color: AppColors.primary, size: 20),
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
                context.read<SettingsCubit>().save(
                      settings.copyWith(delaySeconds: value.toInt()),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
