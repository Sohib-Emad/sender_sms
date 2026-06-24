import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';

class SendNotDefaultSms extends StatelessWidget {
  final List<Student> students;
  final String template;

  const SendNotDefaultSms({super.key, required this.students, required this.template});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sms_rounded, size: 80, color: AppColors.warning),
          const SizedBox(height: 16),
          const Text(
            'تطبيق SMS افتراضي',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'يجب جعل هذا التطبيق افتراضياً لإرسال SMS\nبدون رسائل تأكيد',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showManualGuide(context),
            icon: const Icon(Icons.help_outline_rounded),
            label: const Text('شرح خطوة بخطوة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async => await sl<SmsService>().requestDefaultSmsApp(),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('محاولة فتح الإعدادات تلقائياً', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 8),
          const Divider(indent: 32, endIndent: 32),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              context.read<SendCubit>().startBatch(
                    students: students,
                    template: template,
                    forcePermission: true,
                  );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('إرسال باستخدام صلاحية SMS بدلاً من ذلك', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.read<SendCubit>().reset(),
            child: const Text('العودة', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showManualGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعيين التطبيق افتراضياً', textDirection: TextDirection.rtl),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('1. افتح "الإعدادات" من هاتفك', textDirection: TextDirection.rtl),
              Text('2. اذهب إلى "التطبيقات"', textDirection: TextDirection.rtl),
              Text('3. اختر "إدارة التطبيقات"', textDirection: TextDirection.rtl),
              Text('4. ابحث عن "SMS مُرسِل"', textDirection: TextDirection.rtl),
              Text('5. اضغط على "تعيين كافتراضي"', textDirection: TextDirection.rtl),
              Text('6. اختر "تطبيق SMS"', textDirection: TextDirection.rtl),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              sl<SmsService>().requestDefaultSmsApp();
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('فتح الإعدادات'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
