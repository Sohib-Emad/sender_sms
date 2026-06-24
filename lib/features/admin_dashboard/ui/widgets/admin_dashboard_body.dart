import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_state.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';
import 'user_card.dart';

class AdminDashboardBody extends StatelessWidget {
  const AdminDashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminDashboardCubit, AdminDashboardState>(
      listener: (context, state) {
        if (state is AdminUserCreated) {
          Navigator.pop(context); // Close the bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء المستخدم بنجاح', textDirection: TextDirection.rtl),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AdminDashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<AppUser> users = [];
        if (state is AdminDashboardLoaded) {
          users = state.users;
        }

        if (users.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textHint),
                SizedBox(height: 16),
                Text(
                  'لا يوجد مستخدمين متاحين',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<AdminDashboardCubit>().loadUsers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) => UserCard(user: users[index]),
          ),
        );
      },
    );
  }
}
