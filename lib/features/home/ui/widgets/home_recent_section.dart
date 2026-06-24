import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sender_sms/features/home/logic/home_cubit.dart';
import 'session_card.dart';
import 'empty_state.dart';

class HomeRecentSection extends StatelessWidget {
  final HomeState state;
  const HomeRecentSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is! HomeLoaded || (state as HomeLoaded).recentSessions.isEmpty) {
      return const EmptyState();
    }

    final recentSessions = (state as HomeLoaded).recentSessions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'آخر العمليات',
          style: Theme.of(context).textTheme.titleLarge,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        ...recentSessions.asMap().entries.map((entry) {
          final session = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SessionCard(session: session)
                .animate()
                .slideY(begin: 0.2, duration: 300.ms, delay: (entry.key * 80).ms)
                .fadeIn(),
          );
        }),
      ],
    );
  }
}
