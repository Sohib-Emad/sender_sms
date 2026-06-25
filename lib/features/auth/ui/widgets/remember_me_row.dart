import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class RememberMeRow extends StatefulWidget {
  const RememberMeRow({super.key});

  @override
  State<RememberMeRow> createState() => _RememberMeRowState();
}

class _RememberMeRowState extends State<RememberMeRow> {
  bool _rememberMe = false;

  void _showForgotPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Lottie Animation
              Lottie.asset(
                'assets/Team building.json',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

              const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Cairo',
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              const Text(
                'لإعادة تعيين كلمة المرور، يرجى التواصل مع الدعم الفني أو إدارة النظام مباشرة.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 28),

              // Contact buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final Uri url = Uri.parse('https://wa.me/201096462825');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                      label: const Text(
                        'واتساب',
                        style: TextStyle(
                            fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF25D366), width: 1.5),
                        foregroundColor: const Color(0xFF25D366),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final Uri url =
                            Uri(scheme: 'tel', path: '+201096462825');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.phone_rounded, size: 20),
                      label: const Text(
                        'اتصال مباشر',
                        style: TextStyle(
                            fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (val) => setState(() => _rememberMe = val ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            const Text(
              'تذكرني لـ 30 يوماً',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showForgotPasswordSheet(context),
          child: const Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
