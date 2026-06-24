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
              child: OutlinedButton(
                onPressed: () => _confirmCancel(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                ),
                child: const Text('إلغاء'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => context.read<SendCubit>().pause(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                child: const Text('إيقاف مؤقت'),
              ),
            ),
          ]);
        }
        if (state is SendPaused) {
          return Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _confirmCancel(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                ),
                child: const Text('إلغاء'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => context.read<SendCubit>().resume(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                child: const Text('استكمال'),
              ),
            ),
          ]);
        }
        if (state is SendFailedPendingRetry) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  'فشل الإرسال: ${_translateError(state.errorMessage)}\nاختر إجراء للاستكمال من حيث توقفت.',
                  style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _confirmCancel(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<SendCubit>().skipFailed(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning, width: 1.5),
                    ),
                    child: const Text('تخطي'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => context.read<SendCubit>().retryFailed(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('إعادة محاولة'),
                  ),
                ),
              ]),
            ],
          );
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

  String _translateError(String error) {
    if (error == 'low_balance') {
      return 'رصيد الشريحة غير كافٍ لإرسال الرسالة.';
    }
    if (error == 'generic_failure') {
      return 'فشل عام في الإرسال (تأكد من الرصيد، صلاحية التطبيق، وصيغة الرقم).';
    }
    if (error == 'no_service') {
      return 'لا توجد شبكة تغطية حالياً (No Service).';
    }
    if (error == 'radio_off') {
      return 'الاتصال اللاسلكي مغلق (ربما وضع الطيران مفعل).';
    }
    if (error == 'null_pdu') {
      return 'فشل توليد محتوى الرسالة (Null PDU).';
    }
    if (error == 'limit_exceeded') {
      return 'تم تجاوز الحد الأقصى المسموح به لإرسال الرسائل.';
    }
    if (error == 'permission_denied') {
      return 'صلاحية إرسال الرسائل (SMS Permission) مرفوضة.';
    }
    if (error == 'timeout') {
      return 'انتهت مهلة محاولة الإرسال (Timeout).';
    }
    if (error.startsWith('error_code_')) {
      final code = error.replaceFirst('error_code_', '');
      return 'فشل بسبب كود خطأ أندرويد: $code';
    }
    return error;
  }
}
