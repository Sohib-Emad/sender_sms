import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;
  final bool isSmallText;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    this.isSmallText = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeBgColor = color.withValues(alpha: 0.1);
    final badgeTextColor = color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF0), width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Colored Badge
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: badgeTextColor,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallText ? 13 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.97, 0.97),
          duration: 350.ms,
          delay: delay.ms,
          curve: Curves.easeOutQuad,
        )
        .fadeIn(duration: 300.ms, delay: delay.ms);
  }
}
