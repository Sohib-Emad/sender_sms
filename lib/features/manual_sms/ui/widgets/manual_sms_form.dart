import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/core/utils/extensions.dart';

class ManualSmsForm extends StatefulWidget {
  const ManualSmsForm({super.key});

  @override
  State<ManualSmsForm> createState() => _ManualSmsFormState();
}

class _ManualSmsFormState extends State<ManualSmsForm> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _smsService = sl<SmsService>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    try {
      final isDefault = await _smsService.isDefaultSmsApp();
      if (!isDefault) {
        final status = await Permission.sms.request();
        if (!status.isGranted) {
          if (mounted) context.showSnack('تم رفض صلاحية إرسال SMS', isError: true);
          return;
        }
      }
      final result = await _smsService.sendSms(
        to: _phoneController.text.trim(),
        message: _messageController.text,
      );
      if (!mounted) return;
      if (result.success) {
        _showSuccessDialog();
      } else if (result.isLowBalance) {
        context.showSnack('الرصيد غير كافٍ للإرسال', isError: true);
      } else {
        context.showSnack('فشل إرسال الرسالة', isError: true);
      }
    } catch (e) {
      if (mounted) context.showSnack('خطأ: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تم الإرسال', textDirection: TextDirection.rtl),
        content: const Text('تم إرسال الرسالة بنجاح', textDirection: TextDirection.rtl),
        actions: [
          ElevatedButton(
            onPressed: () {
              _phoneController.clear();
              _messageController.clear();
              Navigator.pop(context);
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('بيانات المستلم', style: Theme.of(context).textTheme.titleMedium, textDirection: TextDirection.rtl),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_rounded)),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال رقم الهاتف' : (v.trim().length < 8 ? 'رقم غير صحيح' : null),
          ),
          const SizedBox(height: 20),
          Text('نص الرسالة', style: Theme.of(context).textTheme.titleMedium, textDirection: TextDirection.rtl),
          const SizedBox(height: 12),
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(labelText: 'اكتب الرسالة هنا', alignLabelWithHint: true),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء كتابة نص الرسالة' : null,
          ),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: Text('عدد الأحرف: ${_messageController.text.length}', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _sendSms,
              icon: _isSending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded),
              label: Text(_isSending ? 'جارٍ الإرسال...' : 'إرسال'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
