import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/injection.dart';
import '../../data/datasources/sms/sms_service.dart';
import '../../core/utils/extensions.dart';

class ManualSmsScreen extends StatefulWidget {
  const ManualSmsScreen({super.key});

  @override
  State<ManualSmsScreen> createState() => _ManualSmsScreenState();
}

class _ManualSmsScreenState extends State<ManualSmsScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _smsService = sl<SmsService>();
  bool _isSending = false;

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
      final status = await Permission.sms.request();
      if (!status.isGranted) {
        if (!mounted) return;
        context.showSnack('تم رفض صلاحية إرسال SMS', isError: true);
        return;
      }

      final success = await _smsService.sendSms(
        to: _phoneController.text.trim(),
        message: _messageController.text,
      );

      if (!mounted) return;

      if (success) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('تم الإرسال', textDirection: TextDirection.rtl),
            content: const Text('تم إرسال الرسالة بنجاح',
                textDirection: TextDirection.rtl),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _phoneController.clear();
                  _messageController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      } else {
        context.showSnack('فشل إرسال الرسالة', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      context.showSnack('خطأ: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال يدوي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'بيانات المستلم',
                  style: Theme.of(context).textTheme.titleMedium,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    if (v.trim().length < 8) {
                      return 'رقم غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'نص الرسالة',
                  style: Theme.of(context).textTheme.titleMedium,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'اكتب الرسالة هنا',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'الرجاء كتابة نص الرسالة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'عدد الأحرف: ${_messageController.text.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendSms,
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_isSending ? 'جارٍ الإرسال...' : 'إرسال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
