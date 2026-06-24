import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/home/logic/home_cubit.dart';

import 'widgets/results_actions.dart';
import 'widgets/results_indicator.dart';
import 'widgets/results_stats_row.dart';

class ResultsPage extends StatelessWidget {
  final String sessionId;
  final int total;
  final int sent;
  final int failed;

  const ResultsPage({
    super.key,
    required this.sessionId,
    required this.total,
    required this.sent,
    required this.failed,
  });

  double get _successRate => total == 0 ? 0 : (sent / total * 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج الإرسال'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              sl<HomeCubit>().loadStats();
              context.go(AppRoutes.home);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ResultsIndicator(successRate: _successRate, isFullSuccess: failed == 0)
                  .animate()
                  .slideY(begin: -0.2, duration: 500.ms)
                  .fadeIn(),
              const SizedBox(height: 24),
              ResultsStatsRow(total: total, sent: sent, failed: failed),
              const SizedBox(height: 24),
              ResultsActions(sessionId: sessionId, failed: failed),
            ],
          ),
        ),
      ),
    );
  }
}
