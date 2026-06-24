import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class PreviewStatsRow extends StatelessWidget {
  final int totalCount;
  final int filteredCount;

  const PreviewStatsRow({
    super.key,
    required this.totalCount,
    required this.filteredCount,
  });

  @override
  Widget build(BuildContext context) {
    final showFiltered = filteredCount != totalCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('إجمالي: $totalCount طالب',
              style: Theme.of(context).textTheme.bodySmall, textDirection: TextDirection.rtl),
          if (showFiltered) ...[
            const SizedBox(width: 8),
            Text('• معروض: $filteredCount',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                textDirection: TextDirection.rtl),
          ],
        ],
      ),
    );
  }
}
