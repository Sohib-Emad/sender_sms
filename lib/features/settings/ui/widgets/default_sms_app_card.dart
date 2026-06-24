import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/services/sms_service.dart';

class DefaultSmsAppCard extends StatefulWidget {
  const DefaultSmsAppCard({super.key});

  @override
  State<DefaultSmsAppCard> createState() => _DefaultSmsAppCardState();
}

class _DefaultSmsAppCardState extends State<DefaultSmsAppCard>
    with WidgetsBindingObserver {
  bool _isDefault = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkDefaultStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDefaultStatus();
    }
  }

  Future<void> _checkDefaultStatus() async {
    try {
      final isDefault = await sl<SmsService>().isDefaultSmsApp();
      if (mounted) {
        setState(() {
          _isDefault = isDefault;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestDefault() async {
    setState(() => _isLoading = true);
    try {
      final result = await sl<SmsService>().requestDefaultSmsApp();
      if (mounted) {
        setState(() {
          _isDefault = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر فتح إعدادات النظام، يرجى المحاولة يدوياً'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _isDefault
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'تطبيق الـ SMS الافتراضي',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.sms_rounded,
                  color: _isDefault ? AppColors.success : AppColors.warning,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isDefault
                  ? 'التطبيق مفعّل حالياً كتطبيق SMS افتراضي. يمكنك الآن إرسال الرسائل بشكل تلقائي وبسرعة قصوى دون قيود.'
                  : 'التطبيق ليس تطبيق SMS الافتراضي. يرجى تعيينه كافتراضي لتتمكن من إرسال الرسائل تلقائياً دفعة واحدة ودون الحاجة لتأكيد إرسال كل رسالة يدوياً.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _isDefault
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        textDirection: TextDirection.rtl,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'تطبيقك الافتراضي الحالي',
                            style: TextStyle(
                              color:
                                  AppColors.primaryDark.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _requestDefault,
                        icon: const Icon(Icons.swap_horizontal_circle_outlined,
                            size: 18),
                        label: const Text(
                          'تعيين كتطبيق افتراضي',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
