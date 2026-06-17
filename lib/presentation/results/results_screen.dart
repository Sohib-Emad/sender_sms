import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../domain/usecases/export_report_usecase.dart';
import '../home/bloc/home_bloc.dart';
import '../home/bloc/home_event.dart';

class ResultsScreen extends StatelessWidget {
  final String sessionId;
  final int total;
  final int sent;
  final int failed;

  const ResultsScreen({
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
        title: const Text(AppStrings.results),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              sl<HomeBloc>().add(HomeLoadStats());
              context.go(AppRouter.home);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSuccessIndicator(context),
              const SizedBox(height: 24),
              _buildStatsRow(context),
              const SizedBox(height: 24),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIndicator(BuildContext context) {
    final isFullSuccess = failed == 0;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFullSuccess
              ? AppColors.successGradient
              : AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isFullSuccess ? AppColors.success : AppColors.primary)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isFullSuccess
                ? Icons.check_circle_rounded
                : Icons.done_all_rounded,
            color: Colors.white,
            size: 64,
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 16),
          Text(
            AppStrings.sendingComplete,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: _successRate / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_successRate.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppStrings.successRate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(duration: 500.ms, delay: 300.ms)
              .fadeIn(delay: 300.ms),
        ],
      ),
    ).animate().slideY(begin: -0.2, duration: 500.ms).fadeIn();
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ResultCard(
            label: 'فشل الإرسال',
            value: '$failed',
            icon: Icons.cancel_rounded,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ResultCard(
            label: 'تم الإرسال',
            value: '$sent',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ResultCard(
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

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        if (failed > 0) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push(AppRouter.failedMessages, extra: sessionId),
              icon: const Icon(Icons.warning_rounded),
              label: Text('${AppStrings.viewFailed} ($failed)'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareReport(context),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text(AppStrings.shareReport),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportReport(context),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text(AppStrings.exportReport),
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
              sl<HomeBloc>().add(HomeLoadStats());
              context.go(AppRouter.home);
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

  Future<void> _exportReport(BuildContext context) async {
    try {
      final exportUseCase = sl<ExportReportUseCase>();
      final path = await exportUseCase(sessionId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.exportSuccess}: $path',
                textDirection: TextDirection.rtl),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}',
                textDirection: TextDirection.rtl),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareReport(BuildContext context) async {
    try {
      final exportUseCase = sl<ExportReportUseCase>();
      final path = await exportUseCase(sessionId);
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'تقرير إرسال SMS',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}',
                textDirection: TextDirection.rtl),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
