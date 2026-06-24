import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';

class SendErrorWidget extends StatelessWidget {
  final SendProgress progress;

  const SendErrorWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 64, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            const Text(
              'فشل إرسال الرسائل',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            if (progress.errorMessage != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 0.5),
                ),
                child: Text(
                  _translateError(progress.errorMessage!),
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'تم إيقاف عملية الإرسال تلقائياً.\nتم إرسال ${progress.sent} رسالة بنجاح من إجمالي ${progress.total}.',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 32),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.read<SendCubit>().reset();
                    context.pop();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('العودة والرجوع'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  String _translateError(String error) {
    if (error == 'low_balance') {
      return 'الرصيد غير كافٍ في شريحة الاتصال.';
    }
    if (error.contains('124')) {
      return 'مشكلة في شبكة الاتصال أو شريحة الـ SIM (رمز: 124).\nتأكد من وجود تغطية للشبكة، تفعيل VoLTE، أو توفر رصيد كافٍ.';
    }
    if (error.contains('RESULT_ERROR_NO_SERVICE')) {
      return 'لا توجد تغطية للشبكة حالياً. يرجى التحقق من الشبكة.';
    }
    if (error.contains('RESULT_ERROR_RADIO_OFF')) {
      return 'الاتصال اللاسلكي مغلق (ربما وضع الطيران مفعل).';
    }
    if (error.contains('RESULT_ERROR_LIMIT_EXCEEDED')) {
      return 'تم تجاوز الحد الأقصى لعدد الرسائل المسموح بإرسالها.';
    }
    if (error.contains('timeout')) {
      return 'انتهت مهلة محاولة الإرسال (تأخر الرد من نظام الهاتف).';
    }
    if (error.contains('الإذن مطلوب') || error.contains('ليس لديك صلاحية')) {
      return 'يرجى إعطاء صلاحية إرسال الرسائل للتطبيق من إعدادات الهاتف.';
    }
    return 'تفاصيل الخطأ: $error';
  }
}
