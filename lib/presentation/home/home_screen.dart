import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/sms_session.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Cards
                    _buildStatsSection(context, state),
                    const SizedBox(height: 24),
                    // Action Buttons
                    _buildActionsSection(context),
                    const SizedBox(height: 24),
                    // Recent Sessions
                    _buildRecentSection(context, state),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 22),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            AppStrings.appSubtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          onPressed: () => context.push(AppRouter.settings),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, HomeState state) {
    int students = 0, sent = 0, failed = 0;
    String lastSession = 'لا يوجد';

    if (state is HomeLoaded) {
      students = state.totalStudents;
      sent = state.totalSent;
      failed = state.totalFailed;
      lastSession = state.lastSession?.date.relativeTime ?? 'لا يوجد';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الإحصائيات',
          style: Theme.of(context).textTheme.titleLarge,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: AppStrings.messagesFailed,
                value: failed.withCommas(),
                icon: Icons.cancel_rounded,
                color: AppColors.statRed,
                delay: 300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: AppStrings.messagesSent,
                value: sent.withCommas(),
                icon: Icons.check_circle_rounded,
                color: AppColors.statGreen,
                delay: 200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: AppStrings.lastSession,
                value: lastSession,
                icon: Icons.access_time_rounded,
                color: AppColors.statOrange,
                delay: 400,
                isSmallText: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: AppStrings.totalStudents,
                value: students.withCommas(),
                icon: Icons.people_rounded,
                color: AppColors.statBlue,
                delay: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الإجراءات',
          style: Theme.of(context).textTheme.titleLarge,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        // Primary action - Import Excel
        _ActionCard(
          title: AppStrings.importExcel,
          subtitle: 'xlsx, xls - ابدأ عملية إرسال جديدة',
          icon: Icons.upload_file_rounded,
          gradient: AppColors.primaryGradient,
          onTap: () => context.push(AppRouter.importExcel),
        ).animate().slideX(begin: 0.3, duration: 400.ms).fadeIn(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'إرسال يدوي',
                subtitle: 'رقم واحد',
                icon: Icons.sms_rounded,
                gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                onTap: () => context.push(AppRouter.manualSms),
                isSmall: true,
              ).animate().slideX(begin: 0.3, duration: 400.ms, delay: 100.ms).fadeIn(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: AppStrings.viewHistory,
                subtitle: 'السجل',
                icon: Icons.history_rounded,
                gradient: const [Color(0xFF334155), Color(0xFF475569)],
                onTap: () => context.push(AppRouter.history),
                isSmall: true,
              ).animate().slideX(begin: 0.3, duration: 400.ms, delay: 200.ms).fadeIn(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context, HomeState state) {
    if (state is! HomeLoaded || state.recentSessions.isEmpty) {
      return _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'آخر العمليات',
          style: Theme.of(context).textTheme.titleLarge,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        ...state.recentSessions.asMap().entries.map((entry) {
          final session = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SessionCard(session: session)
                .animate()
                .slideY(begin: 0.2, duration: 300.ms, delay: (entry.key * 80).ms)
                .fadeIn(),
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;
  final bool isSmallText;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    this.isSmallText = false,
  });

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: isSmallText
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                        : Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: 400.ms,
          delay: delay.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 300.ms, delay: delay.ms);
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final bool isSmall;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isSmall) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: isSmall ? 18 : 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SmsSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final successRate = session.successRate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success rate circle
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: successRate / 100,
                        backgroundColor: AppColors.error.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                        strokeWidth: 5,
                      ),
                      Center(
                        child: Text(
                          '${successRate.toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  session.date.relativeTime,
                  style: Theme.of(context).textTheme.bodySmall,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'فشل: ${session.failed}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 8),
                    Text(
                      'نجح: ${session.success}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'إجمالي: ${session.total} رسالة',
                  style: Theme.of(context).textTheme.titleSmall,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.noHistory,
            style: Theme.of(context).textTheme.bodyMedium,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
