import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavBarItem(icon: Icons.home_rounded, label: 'الرئيسية'),
      _NavBarItem(icon: Icons.calendar_today_rounded, label: 'السجل'),
      _NavBarItem(icon: Icons.chat_bubble_rounded, label: 'إرسال يدوي'),
      _NavBarItem(icon: Icons.person_rounded, label: 'الإعدادات'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary.withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavBarItem {
  final IconData icon;
  final String label;

  _NavBarItem({required this.icon, required this.label});
}
