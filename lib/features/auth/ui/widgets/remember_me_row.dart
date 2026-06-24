import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class RememberMeRow extends StatefulWidget {
  const RememberMeRow({super.key});

  @override
  State<RememberMeRow> createState() => _RememberMeRowState();
}

class _RememberMeRowState extends State<RememberMeRow> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (val) => setState(() => _rememberMe = val ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            const Text(
              'تذكرني لـ 30 يوماً',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الخدمة غير متوفرة حالياً', textDirection: TextDirection.rtl)),
          ),
          child: const Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
