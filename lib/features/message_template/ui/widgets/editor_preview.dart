import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class EditorPreview extends StatelessWidget {
  final String previewMessage;

  const EditorPreview({super.key, required this.previewMessage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Divider(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('معاينة الرسالة', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.preview_rounded, size: 18, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Text(
            previewMessage,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
