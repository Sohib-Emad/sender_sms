import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'widgets/add_user_bottom_sheet.dart';
import 'widgets/admin_dashboard_body.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardCubit>().loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'لوحة تحكم المسؤول',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => context.read<AuthCubit>().signOut(),
            tooltip: 'تسجيل الخروج',
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
        ),
        elevation: 2,
      ),
      body: const AdminDashboardBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserBottomSheet(context),
        label: const Text(
          'إضافة مستخدم',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAddUserBottomSheet(BuildContext pageContext) {
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return BlocProvider<AdminDashboardCubit>.value(
          value: pageContext.read<AdminDashboardCubit>(),
          child: const AddUserBottomSheet(),
        );
      },
    );
  }
}
