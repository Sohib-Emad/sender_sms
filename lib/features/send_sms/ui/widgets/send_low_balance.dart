import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';
import 'package:sender_sms/features/send_sms/logic/send_cubit.dart';

class SendLowBalanceWidget extends StatelessWidget {
  final SendProgress progress;

  const SendLowBalanceWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  size: 64, color: AppColors.warning),
            ),
            const SizedBox(height: 24),
            const Text(
              'الرصيد غير كافٍ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Text(
              'توقف الإرسال تلقائياً. تم إرسال ${progress.sent} رسالة من ${progress.total}.',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 32),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<SendCubit>().reset();
                    context.pop();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('العودة'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
