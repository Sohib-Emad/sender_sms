import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/routing/app_routes.dart';

class FeaturedActionCard extends StatelessWidget {
  const FeaturedActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF0), width: 0.5),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                const Text(
                  'ابدأ إرسال رسائل جديدة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'استورد ملف Excel يحتوي على بيانات الطلاب ودرجاتهم لبدء الإرسال الجماعي فوراً وبطريقة مبسطة.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push(AppRoutes.importExcel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('استيراد Excel',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
