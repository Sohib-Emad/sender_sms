import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';

class SendNotDefaultSms extends StatefulWidget {
  final List<Student> students;
  final String template;

  const SendNotDefaultSms({
    super.key,
    required this.students,
    required this.template,
  });

  @override
  State<SendNotDefaultSms> createState() => _SendNotDefaultSmsState();
}

class _SendNotDefaultSmsState extends State<SendNotDefaultSms>
    with WidgetsBindingObserver {

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfBecameDefault();
    }
  }

  Future<void> _checkIfBecameDefault() async {
    final isDefault = await sl<SmsService>().isDefaultSmsApp();
    if (isDefault && mounted) {
      // أصبح افتراضي - ابدأ الإرسال تلقائياً
      context.read<SendCubit>().startBatch(
            students: widget.students,
            template: widget.template,
            forcePermission: false,
          );
    }
  }

  Future<void> _requestDefault() async {
    setState(() => _isLoading = true);
    try {
      await sl<SmsService>().requestDefaultSmsApp();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر فتح الإعدادات، يرجى المحاولة يدوياً'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

          // الزر الرئيسي
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _requestDefault,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.open_in_new),
            label: Text(_isLoading ? 'جاري الفتح...' : 'تعيين كتطبيق افتراضي'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          // دليل يدوي
          TextButton.icon(
            onPressed: () => _showManualGuide(context),
            icon: const Icon(Icons.help_outline_rounded, size: 16),
            label: const Text('شرح خطوة بخطوة', style: TextStyle(fontSize: 13)),
          ),

          const SizedBox(height: 8),
          const Divider(indent: 32, endIndent: 32),
          const SizedBox(height: 8),

          // إرسال بالصلاحية العادية
          TextButton.icon(
            onPressed: () {
              context.read<SendCubit>().startBatch(
                    students: widget.students,
                    template: widget.template,
                    forcePermission: true,
                  );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text(
              'إرسال باستخدام صلاحية SMS بدلاً من ذلك',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),

          TextButton(
            onPressed: () => context.read<SendCubit>().reset(),
            child: const Text(
              'العودة',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تعيين التطبيق افتراضياً',
          textDirection: TextDirection.rtl,
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StepTile(number: '١', text: 'افتح "الإعدادات" من هاتفك'),
              _StepTile(number: '٢', text: 'اختر "التطبيقات"'),
              _StepTile(number: '٣', text: 'اضغط ⋮ واختر "التطبيقات الافتراضية"'),
              _StepTile(number: '٤', text: 'اختر "تطبيق الرسائل"'),
              _StepTile(number: '٥', text: 'اختر "SMS مُرسِل"'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _requestDefault();
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String number;
  final String text;

  const _StepTile({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text, textDirection: TextDirection.rtl),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: Text(
              number,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}