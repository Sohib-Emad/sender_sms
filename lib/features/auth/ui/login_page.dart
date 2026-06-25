import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'package:sender_sms/features/auth/logic/auth_state.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    _requestAllPermissions();
  }

  Future<void> _requestAllPermissions() async {
    await [
      Permission.sms,
      Permission.phone,
      Permission.notification,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isError = state is AuthError;

        return Scaffold(
          backgroundColor: (isLoading || isError) ? Colors.white : AppColors.lightBackground,
          body: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go(
                    state.user.isAdmin ? AppRoutes.adminDashboard : AppRoutes.home);
              } else if (state is AuthBlocked) {
                _showBlockedDialog(context, state.message);
              }
            },
            child: isLoading
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/login.json',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'جاري تسجيل الدخول...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : isError
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/forgot password.json',
                                width: 250,
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                  fontFamily: 'Cairo',
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'يرجى التحقق من البيانات المدخلة والمحاولة مرة أخرى.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Cairo',
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () => context.read<AuthCubit>().reset(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'إعادة المحاولة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 130),
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
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.8),
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
      },
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
