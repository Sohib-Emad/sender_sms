import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(width: 8),
        Container(
          height: 2,
          width: 30,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}
