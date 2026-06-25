import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.read<AuthCubit>().signOut(),
        icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
            fontSize: 15,
            fontFamily: 'Cairo',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorLight,
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

