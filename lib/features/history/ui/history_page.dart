import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sender_sms/core/constants/screen_strings.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/history/logic/history_cubit.dart';
import 'widgets/history_session_card.dart';

class HistoryPage extends StatelessWidget {
  final bool isTab;
  const HistoryPage({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل العمليات'),
        automaticallyImplyLeading: !isTab,
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.pop(),
              ),
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryLoaded) {
            final sessions = state.sessions;
            if (sessions.isEmpty) return _buildEmpty(context);

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final session = sessions[i];
                return HistorySessionCard(session: session)
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
            ScreenStrings.noHistory,
            style: Theme.of(context).textTheme.bodyLarge,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.importExcel),
            icon: const Icon(Icons.add_rounded),
            label: const Text('ابدأ عملية إرسال'),
          ),
        ],
      ),
    );
  }
}
