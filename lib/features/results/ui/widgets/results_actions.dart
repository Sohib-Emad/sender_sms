import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/home/logic/home_cubit.dart';
import 'package:sender_sms/features/results/logic/results_helper.dart';

class ResultsActions extends StatelessWidget {
  final String sessionId;
  final int failed;

  const ResultsActions({
    super.key,
    required this.sessionId,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (failed > 0) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.failedMessages, extra: sessionId),
              icon: const Icon(Icons.warning_rounded),
              label: Text('عرض الفاشلين ($failed)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ResultsHelper.handleShare(context, sessionId),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('مشاركة التقرير'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ResultsHelper.handleExport(context, sessionId),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('تصدير التقرير'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              sl<HomeCubit>().loadStats();
              context.go(AppRoutes.home);
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('العودة للرئيسية'),
          ),
        ),
      ],
    )
        .animate()
        .slideY(begin: 0.3, duration: 500.ms, delay: 400.ms)
        .fadeIn(delay: 400.ms);
  }
}
