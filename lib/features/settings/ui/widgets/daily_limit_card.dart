import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class DailyLimitCard extends StatelessWidget {
  final AppSettings settings;
  const DailyLimitCard({super.key, required this.settings});

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
                Switch(
                  value: settings.dailyLimit > 0,
                  onChanged: (v) {
                    context.read<SettingsCubit>().save(
                          settings.copyWith(dailyLimit: v ? 100 : 0),
                        );
                  },
                ),
                Row(
                  children: [
                    Text(
                      ScreenStrings.dailyLimit,
                      style: Theme.of(context).textTheme.titleMedium,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.block_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ],
            ),
            if (settings.dailyLimit > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${settings.dailyLimit} رسالة/يوم',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'الحد اليومي',
                    style: Theme.of(context).textTheme.bodySmall,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              Slider(
                value: settings.dailyLimit.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                label: '${settings.dailyLimit}',
                onChanged: (v) {
                  context.read<SettingsCubit>().save(
                        settings.copyWith(dailyLimit: v.toInt()),
                      );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
