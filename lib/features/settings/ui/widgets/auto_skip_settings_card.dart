import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/features/settings/data/models/app_settings.dart';
import 'package:sender_sms/features/settings/logic/settings_cubit.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class AutoSkipSettingsCard extends StatelessWidget {
  final AppSettings settings;
  const AutoSkipSettingsCard({super.key, required this.settings});

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
                  value: settings.autoSkipFailed,
                  onChanged: (v) {
                    context.read<SettingsCubit>().save(
                          settings.copyWith(autoSkipFailed: v),
                        );
                  },
                ),
                Row(
                  children: [
                    Text(
                      'تخطي الأرقام الفاشلة تلقائياً',
                      style: Theme.of(context).textTheme.titleMedium,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.skip_next_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'عند التفعيل، سيقوم التطبيق بتخطي أي رقم يفشل إرسال الرسالة إليه تلقائياً ومتابعة إرسال باقي الرسائل في القائمة دون توقف.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
