import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/app_strings.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class CancelConfirmDialog extends StatelessWidget {
  const CancelConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إلغاء الإرسال', textDirection: TextDirection.rtl),
      content: const Text(ScreenStrings.confirmCancel, textDirection: TextDirection.rtl),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.no),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text(AppStrings.yes, style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
