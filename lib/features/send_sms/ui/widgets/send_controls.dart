import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';
import 'package:sender_sms/features/send_sms/logic/send_state.dart';
import 'cancel_confirm_dialog.dart';

class SendControls extends StatelessWidget {
  final List<Student> students;
  final String template;

  const SendControls({super.key, required this.students, required this.template});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendCubit, SendState>(
      builder: (context, state) {
        if (state is SendIdle || state is SendRequestingPermission) {
          return SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: state is SendRequestingPermission
                  ? null
                  : () => context.read<SendCubit>().startBatch(students: students, template: template),
              icon: const Icon(Icons.send_rounded),
              label: Text('بدء الإرسال (${students.length})'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            ),
          );
        }
        if (state is SendInProgress) {
          return Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: const Icon(Icons.stop_rounded, color: AppColors.error),
                label: const Text('إلغاء', style: TextStyle(color: AppColors.error)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => context.read<SendCubit>().pause(),
                icon: const Icon(Icons.pause_rounded),
                label: const Text('إيقاف مؤقت'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
              ),
            ),
          ]);
        }
        if (state is SendPaused) {
          return Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: const Icon(Icons.stop_rounded, color: AppColors.error),
                label: const Text('إلغاء', style: TextStyle(color: AppColors.error)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => context.read<SendCubit>().resume(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('استكمال'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              ),
            ),
          ]);
        }
        if (state is SendCancelled) {
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<SendCubit>().reset();
                context.pop();
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('العودة'),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog<bool>(context: context, builder: (_) => const CancelConfirmDialog()).then((c) {
      if (c == true && context.mounted) {
        context.read<SendCubit>().cancel();
      }
    });
  }
}
