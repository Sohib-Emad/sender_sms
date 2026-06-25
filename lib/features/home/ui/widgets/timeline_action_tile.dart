import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class TimelineActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final bool isLast;

  const TimelineActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF0), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Green Icon Container (36x36, radius 10, bg #E8F5EE)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Chevron Arrow
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
