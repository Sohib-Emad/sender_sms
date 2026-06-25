import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';

class FailedLogCard extends StatelessWidget {
  final SmsLog log;
  final VoidCallback onRetry;

  const FailedLogCard({super.key, required this.log, required this.onRetry});

  String get _errorLabel {
    final error = log.errorMessage ?? '';
    if (error.contains('رصيد') || error.toLowerCase().contains('balance')) {
      return 'رصيد غير كافٍ';
    } else if (error.contains('رقم') || error.toLowerCase().contains('invalid')) {
      return 'رقم غير صحيح';
    } else if (error.toLowerCase().contains('network')) {
      return 'مشكلة في الشبكة';
    } else if (error.isEmpty) {
      return 'فشل النظام';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      log.studentName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      log.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  const Text(
                    'سبب الفشل: ',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _errorLabel,
                      style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
