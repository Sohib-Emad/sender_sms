import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'package:sender_sms/features/auth/logic/auth_state.dart';
import 'remember_me_row.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'البريد الإلكتروني',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: 'أدخل البريد الإلكتروني',
            ),
            validator: (v) => (v == null || !v.contains('@')) ? 'بريد إلكتروني غير صحيح' : null,
          ),
          const SizedBox(height: 18),
          const Text(
            'كلمة المرور',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: 'أدخل كلمة المرور',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور قصيرة' : null,
          ),
          const SizedBox(height: 16),
          const RememberMeRow(),
          const SizedBox(height: 28),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state is AuthLoading ? null : _submit,
                child: state is AuthLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }
}
