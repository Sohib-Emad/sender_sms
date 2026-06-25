import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'package:sender_sms/features/auth/logic/auth_state.dart';
import 'package:sender_sms/features/notifications/logic/notifications_cubit.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = 'المستخدم';
        if (state is AuthAuthenticated) {
          name = state.user.displayName;
        }

        return SliverAppBar(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          pinned: true,
          automaticallyImplyLeading: false,
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                int unread = 0;
                if (state is NotificationsLoaded) {
                  unread = state.unreadCount;
                }
                return IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: AppColors.textPrimary,
                        size: 26,
                      ),
                      if (unread > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    context.push(AppRoutes.notifications);
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          title: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  const Text(
                    'أهلاً بك،',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
