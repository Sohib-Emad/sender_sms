import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/utils/extensions.dart';
import 'package:sender_sms/features/history/data/models/sms_session.dart';

class SessionCard extends StatelessWidget {
  final SmsSession session;
  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final successRate = session.successRate;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Success Rate Indicator
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: successRate / 100,
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.success),
                    strokeWidth: 4,
                  ),
                  Center(
                    child: Text(
                      '${successRate.toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'عملية إرسال دفعة',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                      ),
                      Text(
                        session.date.relativeTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'نجح: ${session.success}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'فشل: ${session.failed}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'الإجمالي: ${session.total}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
