import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'package:sender_sms/features/auth/logic/auth_state.dart';

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
          title: Row(
            textDirection: TextDirection.rtl,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary, size: 22),
              onPressed: () => context.read<AuthCubit>().signOut(),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        );
      },
    );
  }
}
