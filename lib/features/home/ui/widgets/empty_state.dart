import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 12),
          Text(
            ScreenStrings.noHistory,
            style: Theme.of(context).textTheme.bodyMedium,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
