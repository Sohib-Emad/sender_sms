import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/utils/extensions.dart';
import 'package:sender_sms/features/history/data/models/sms_session.dart';

class HistorySessionCard extends StatelessWidget {
  final SmsSession session;
  const HistorySessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final successRate = session.total > 0 ? (session.success / session.total * 100).toInt() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: successRate / 100,
                            strokeWidth: 6,
                            backgroundColor: AppColors.error.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              successRate > 80 ? AppColors.success : AppColors.warning,
                            ),
                          ),
                          Center(
                            child: Text(
                              '$successRate%',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: session.status == 'completed' ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        session.status == 'completed' ? 'مكتمل' : 'ملغي',
                        style: TextStyle(
                          fontSize: 10,
                          color: session.status == 'completed' ? AppColors.success : AppColors.warning,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      session.date.formattedDateTime,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatChip(label: '${session.failed} فاشل', color: AppColors.error),
                        const SizedBox(width: 8),
                        _StatChip(label: '${session.success} نجح', color: AppColors.success),
                        const SizedBox(width: 8),
                        _StatChip(label: '${session.total} إجمالي', color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
