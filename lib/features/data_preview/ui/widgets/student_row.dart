import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';

class StudentRow extends StatelessWidget {
  final Student student;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentRow({
    super.key,
    required this.student,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            student.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              student.degree,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            student.phone,
            style: Theme.of(context).textTheme.bodySmall,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_rounded, size: 20, color: AppColors.error),
            onPressed: onDelete,
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20, color: AppColors.primary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
