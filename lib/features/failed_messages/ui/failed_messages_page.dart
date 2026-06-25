import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/failed_messages/logic/failed_cubit.dart';
import 'package:sender_sms/features/failed_messages/logic/failed_state.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';

import 'widgets/failed_empty_state.dart';
import 'widgets/failed_log_card.dart';

class FailedMessagesPage extends StatelessWidget {
  final String sessionId;
  const FailedMessagesPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FailedCubit>()..loadFailedLogs(sessionId),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('الرسائل الفاشلة'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              BlocBuilder<FailedCubit, FailedState>(
                builder: (context, state) {
                  if (state is FailedLoaded && state.failedLogs.isNotEmpty) {
                    return TextButton.icon(
                      onPressed: () => _retryAll(context, state.failedLogs),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('إعادة إرسال الكل'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<FailedCubit, FailedState>(
            builder: (context, state) {
              if (state is FailedLoading) return const Center(child: CircularProgressIndicator());
              if (state is FailedError) return Center(child: Text(state.message));
              if (state is FailedLoaded) {
                final logs = state.failedLogs;
                if (logs.isEmpty) return const FailedEmptyState();
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (c, idx) {
                    final log = logs[idx];
                    return FailedLogCard(log: log, onRetry: () => _retrySingle(context, log));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _retrySingle(BuildContext context, SmsLog log) async {
    final success = await context.read<FailedCubit>().retrySingle(log);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'تم إرسال الرسالة بنجاح' : 'فشلت محاولة إعادة الإرسال',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  void _retryAll(BuildContext context, List<SmsLog> logs) {
    final students = logs
        .map((l) => Student(
              id: l.id,
              name: l.studentName,
              phone: l.phone,
              degree: l.message,
              createdAt: DateTime.now(),
            ))
        .toList();

    context.push(AppRoutes.sendSms, extra: {
      'students': students,
      'template': '{degree}',
    });
  }
}
