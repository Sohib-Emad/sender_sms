import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';

class SendCancelledState extends StatelessWidget {
  final SendProgress progress;
  const SendCancelledState({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel_rounded, size: 80, color: AppColors.warning),
          const SizedBox(height: 16),
          const Text(
            'تم إلغاء الإرسال',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'تم إرسال ${progress.sent} من ${progress.total}',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
