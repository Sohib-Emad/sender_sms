import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'result_card.dart';

class ResultsStatsRow extends StatelessWidget {
  final int total;
  final int sent;
  final int failed;

  const ResultsStatsRow({
    super.key,
    required this.total,
    required this.sent,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ResultCard(
            label: 'فشل الإرسال',
            value: '$failed',
            icon: Icons.cancel_rounded,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ResultCard(
            label: 'تم الإرسال',
            value: '$sent',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ResultCard(
            label: 'الإجمالي',
            value: '$total',
            icon: Icons.all_inclusive_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    )
        .animate()
        .slideY(begin: 0.3, duration: 500.ms, delay: 200.ms)
        .fadeIn(delay: 200.ms);
  }
}
