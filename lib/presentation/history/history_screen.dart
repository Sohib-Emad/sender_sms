import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import 'bloc/history_bloc.dart';
import 'bloc/history_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.sessionsHistory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryLoaded) {
            if (state.sessions.isEmpty) {
              return _buildEmpty(context);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final session = state.sessions[i];
                return _SessionCard(session: session)
                    .animate()
                    .slideX(begin: 0.2, duration: 300.ms, delay: (i * 50).ms)
                    .fadeIn(delay: (i * 50).ms);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppStrings.noHistory,
            style: Theme.of(context).textTheme.bodyLarge,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRouter.importExcel),
            icon: const Icon(Icons.add_rounded),
            label: const Text('ابدأ عملية إرسال'),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final dynamic session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final successRate = session.total > 0
        ? (session.success / session.total * 100).toInt()
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: success circle + status
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
                            backgroundColor: AppColors.error.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              successRate > 80
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          Center(
                            child: Text(
                              '$successRate%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: session.status == 'completed'
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        session.status == 'completed' ? 'مكتمل' : 'ملغي',
                        style: TextStyle(
                          fontSize: 10,
                          color: session.status == 'completed'
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),

                // Right: details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      session.date.formattedDateTime,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatChip(
                          label: '${session.failed} فاشل',
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: '${session.success} نجح',
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: '${session.total} إجمالي',
                          color: AppColors.primary,
                        ),
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
