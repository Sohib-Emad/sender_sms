import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';

class RoleTag extends StatelessWidget {
  final AppUser user;

  const RoleTag({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isBlocked = user.isBlocked;
    final isAdmin = user.isAdmin;

    Color bgColor;
    Color textColor;
    String label;

    if (isBlocked) {
      bgColor = AppColors.errorLight;
      textColor = AppColors.error;
      label = 'محظور';
    } else if (isAdmin) {
      bgColor = AppColors.primaryLight.withValues(alpha: 0.2);
      textColor = AppColors.primaryDark;
      label = 'مسؤول';
    } else {
      bgColor = AppColors.successLight;
      textColor = AppColors.success;
      label = 'مستخدم';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
