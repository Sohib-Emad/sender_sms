import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'save_user_button.dart';

class AddUserForm extends StatefulWidget {
  const AddUserForm({super.key});

  @override
  State<AddUserForm> createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdminUser = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إنشاء مستخدم جديد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                prefixIcon: const Icon(Icons.person_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'يرجى إدخال الاسم' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) =>
                  value == null || value.length < 6 ? 'يجب ألا تقل كلمة المرور عن 6 أحرف' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('صلاحيات المسؤول (Admin)'),
              subtitle: const Text('يسمح للمستخدم بالوصول إلى لوحة التحكم هذه'),
              value: _isAdminUser,
              onChanged: (val) => setState(() => _isAdminUser = val),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 24),
            SaveUserButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<AdminDashboardCubit>().createUser(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        displayName: _nameController.text.trim(),
                        isAdmin: _isAdminUser,
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
