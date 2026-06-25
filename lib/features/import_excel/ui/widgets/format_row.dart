import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class FormatRow extends StatelessWidget {
  final String label;
  final String example;
  final IconData icon;

  const FormatRow({
    super.key,
    required this.label,
    required this.example,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            example,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: AppColors.primary),
      ],
    );
  }
}
