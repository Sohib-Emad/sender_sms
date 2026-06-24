import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';

class VariablesSection extends StatelessWidget {
  final void Function(String) onVariableInsert;

  const VariablesSection({super.key, required this.onVariableInsert});

  static const _variables = [
    ('{name}', 'الاسم', Icons.person_rounded),
    ('{degree}', 'الدرجة', Icons.grade_rounded),
    ('{phone}', 'الهاتف', Icons.phone_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          ScreenStrings.variables,
          style: Theme.of(context).textTheme.titleSmall,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          children: _variables.map((v) {
            return ActionChip(
              avatar: Icon(v.$3, size: 16, color: AppColors.primary),
              label: Text('${v.$1} ${v.$2}', textDirection: TextDirection.rtl),
              onPressed: () => onVariableInsert(v.$1),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
