import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'package:sender_sms/features/auth/logic/auth_state.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(
                state.user.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: AppColors.error,
            ));
          } else if (state is AuthBlocked) {
            _showBlockedDialog(context, state.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'أهلاً بك مجدداً!',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 10),
                Text(
                  'يرجى تسجيل الدخول للمتابعة والوصول إلى حسابك. أدخل بريدك الإلكتروني وكلمة المرور للبدء.',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      height: 1.5),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 32),
                const LoginForm(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBlockedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('الحساب موقوف', textDirection: TextDirection.rtl),
        content: Text(message, textDirection: TextDirection.rtl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً')),
        ],
      ),
    );
  }
}
