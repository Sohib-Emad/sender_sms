import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';
import 'package:sender_sms/features/send_sms/logic/send_state.dart';
import 'widgets/cancel_confirm_dialog.dart';
import 'widgets/send_cancelled_state.dart';
import 'widgets/send_controls.dart';
import 'widgets/send_low_balance.dart';
import 'widgets/send_not_default_sms.dart';
import 'widgets/send_permission_error.dart';
import 'widgets/send_ready_state.dart';
import 'widgets/send_sending_state.dart';
import 'widgets/send_error_widget.dart';

class SendSmsPage extends StatelessWidget {
  final List<Student> students;
  final String template;

  const SendSmsPage({super.key, required this.students, required this.template});

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: sl<SendCubit>(),
        child: Builder(builder: (context) => _buildBody(context)),
      );

  Widget _buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (context.read<SendCubit>().state is! SendInProgress) {
          context.pop();
          return;
        }
        final confirm = await showDialog<bool>(context: context, builder: (_) => const CancelConfirmDialog());
        if (confirm == true && context.mounted) {
          context.read<SendCubit>().cancel();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إرسال SMS'),
          automaticallyImplyLeading: false,
          leading: BlocBuilder<SendCubit, SendState>(
            builder: (context, state) => (state is SendInProgress || state is SendPaused)
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => context.pop(),
                  ),
          ),
        ),
        body: BlocConsumer<SendCubit, SendState>(
          listener: (context, state) {
            if (state is SendCompleted) {
              final p = state.progress;
              context.pushReplacement(AppRoutes.results, extra: {
                'sessionId': p.sessionId, 'total': p.total, 'sent': p.sent, 'failed': p.failed,
              });
            } else if (state is SendPermissionDenied) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم رفض صلاحية إرسال SMS', textDirection: TextDirection.rtl),
                backgroundColor: AppColors.error,
              ));
            }
          },
          builder: (context, state) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _buildContent(state, context)),
                  SendControls(students: students, template: template),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SendState state, BuildContext context) {
    if (state is SendIdle || state is SendRequestingPermission) {
      return SendReadyState(students: students, template: template, isRequesting: state is SendRequestingPermission);
    }
    if (state is SendPermissionDenied) return const SendPermissionError();
    if (state is SendNotDefaultSmsApp) return SendNotDefaultSms(students: students, template: template);
    if (state is SendLowBalance) return SendLowBalanceWidget(progress: state.progress);
    if (state is SendGeneralError) return SendErrorWidget(progress: state.progress);
    if (state is SendCompleted) {
      return SendSendingState(progress: state.progress, isPaused: false);
    }
    if (state is SendInProgress || state is SendPaused) {
      final p = state is SendInProgress ? state.progress : (state as SendPaused).progress;
      return SendSendingState(progress: p, isPaused: state is SendPaused);
    }
    if (state is SendCancelled) return SendCancelledState(progress: state.progress);
    if (state is SendError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ أثناء الإعداد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.read<SendCubit>().reset(),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
