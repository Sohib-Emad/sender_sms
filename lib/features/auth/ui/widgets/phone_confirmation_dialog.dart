import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';
import 'package:sender_sms/core/services/sms_service.dart';
import 'package:sender_sms/core/utils/extensions.dart';

class PhoneConfirmationDialog extends StatefulWidget {
  const PhoneConfirmationDialog({super.key});

  static Future<void> show(BuildContext context) async {
    final hive = sl<HiveDatasource>();
    final confirmedPhone = hive.settingsData.get('confirmed_phone_number') as String?;
    
    if (confirmedPhone != null && confirmedPhone.isNotEmpty) {
      return; // Already confirmed
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PhoneConfirmationDialog(),
    );
  }

  @override
  State<PhoneConfirmationDialog> createState() => _PhoneConfirmationDialogState();
}

class _PhoneConfirmationDialogState extends State<PhoneConfirmationDialog> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _statusMessage = 'جاري التحقق من رقم الهاتف الخاص بك...';

  @override
  void initState() {
    super.initState();
    _detectPhoneNumber();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _detectPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request SMS and Phone state permissions
      final smsStatus = await Permission.sms.request();
      final phoneStatus = await Permission.phone.request();

      if (smsStatus.isGranted || phoneStatus.isGranted) {
        final number = await sl<SmsService>().getDevicePhoneNumber();
        if (number.isNotEmpty) {
          _phoneController.text = number;
          setState(() {
            _statusMessage = 'تم لقط رقم الهاتف من الشريحة بنجاح!';
          });
        } else {
          setState(() {
            _statusMessage = 'تعذر لقط الرقم تلقائياً من الشريحة. يرجى إدخاله يدوياً.';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'الصلاحية مطلوبة للقط الرقم تلقائياً. يرجى كتابته يدوياً.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'حدث خطأ أثناء قراءة الشريحة. يرجى كتابة الرقم يدوياً.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmNumber() async {
    if (!_formKey.currentState!.validate()) return;
    
    final phone = _phoneController.text.trim();
    final hive = sl<HiveDatasource>();
    await hive.settingsData.put('confirmed_phone_number', phone);
    
    if (mounted) {
      context.showSnack('تم تأكيد رقم الهاتف بنجاح');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تأكيد رقم الهاتف',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'الرجاء تأكيد رقم الهاتف الخاص بالشريحة المستخدمة في الإرسال لتوثيق الجلسات بشكل صحيح.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),
              if (_isLoading) ...[
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11, 
                  color: _phoneController.text.isNotEmpty ? AppColors.success : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: 'مثال: 01001112233',
                  prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  if (value.trim().length < 8) {
                    return 'رقم الهاتف غير صحيح';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _confirmNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'تأكيد واستمرار',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
