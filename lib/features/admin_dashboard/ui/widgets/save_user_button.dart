import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_state.dart';

class SaveUserButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SaveUserButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
      builder: (context, state) {
        final isCreating = state is AdminUserCreating;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isCreating ? null : onPressed,
            child: isCreating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'حفظ المستخدم',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
