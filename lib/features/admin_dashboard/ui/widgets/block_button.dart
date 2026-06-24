import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'package:sender_sms/features/auth/data/models/app_user.dart';
import 'toggle_block_confirmation_dialog.dart';

class BlockButton extends StatelessWidget {
  final AppUser user;

  const BlockButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.isAdmin) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(
        user.isBlocked ? Icons.block_flipped : Icons.check_circle_outline_rounded,
        color: user.isBlocked ? AppColors.error : AppColors.success,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (dialogCtx) => BlocProvider<AdminDashboardCubit>.value(
            value: context.read<AdminDashboardCubit>(),
            child: ToggleBlockConfirmationDialog(user: user),
          ),
        );
      },
      tooltip: user.isBlocked ? 'تفعيل الحساب' : 'حظر الحساب',
    );
  }
}
