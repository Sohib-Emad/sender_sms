import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class FailedEmptyState extends StatelessWidget {
  const FailedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
          SizedBox(height: 16),
          Text('لا توجد رسائل فاشلة', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
