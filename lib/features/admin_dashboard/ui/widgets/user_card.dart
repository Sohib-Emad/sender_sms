import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';
import 'role_tag.dart';
import 'stat_item.dart';
import 'block_button.dart';

class UserCard extends StatelessWidget {
  final AppUser user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user.displayName.isNotEmpty
        ? user.displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: user.isAdmin ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.grey.shade100,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: user.isAdmin ? AppColors.primaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          RoleTag(user: user),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                BlockButton(user: user),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(label: 'تم الإرسال', value: user.totalSent.toString(), color: AppColors.success),
                Container(height: 24, width: 0.5, color: Colors.grey.shade300),
                StatItem(label: 'فشل الإرسال', value: user.totalFailed.toString(), color: AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
