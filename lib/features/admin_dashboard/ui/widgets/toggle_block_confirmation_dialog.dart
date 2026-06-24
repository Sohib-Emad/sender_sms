import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';

class ToggleBlockConfirmationDialog extends StatelessWidget {
  final AppUser user;

  const ToggleBlockConfirmationDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        user.isBlocked ? 'تفعيل الحساب' : 'حظر الحساب',
        textDirection: TextDirection.rtl,
      ),
      content: Text(
        user.isBlocked
            ? 'هل أنت متأكد من تفعيل حساب ${user.displayName}؟'
            : 'هل أنت متأكد من حظر حساب ${user.displayName}؟ لن يتمكن من استخدام التطبيق.',
        textDirection: TextDirection.rtl,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            context.read<AdminDashboardCubit>().toggleBlockUser(user.uid, !user.isBlocked);
            Navigator.pop(context);
          },
          child: Text(
            user.isBlocked ? 'تفعيل' : 'حظر',
            style: TextStyle(color: user.isBlocked ? AppColors.success : AppColors.error),
          ),
        ),
      ],
    );
  }
}
