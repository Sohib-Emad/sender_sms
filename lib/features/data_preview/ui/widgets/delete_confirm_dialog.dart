import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/app_strings.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final Student student;

  const DeleteConfirmDialog({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حذف الطالب', textDirection: TextDirection.rtl),
      content: Text('هل تريد حذف "${student.name}"؟', textDirection: TextDirection.rtl),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text(AppStrings.delete),
        ),
      ],
    );
  }
}
