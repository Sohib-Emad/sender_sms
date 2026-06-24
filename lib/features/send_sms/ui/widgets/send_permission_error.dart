import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class SendPermissionError extends StatelessWidget {
  const SendPermissionError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            ScreenStrings.permissionDenied,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            ScreenStrings.permissionRequired,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
