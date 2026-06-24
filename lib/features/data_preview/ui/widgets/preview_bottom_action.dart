import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';

class PreviewBottomAction extends StatelessWidget {
  final List<Student> students;

  const PreviewBottomAction({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: students.isEmpty
              ? null
              : () => context.push(AppRoutes.messageTemplate, extra: students),
          icon: const Icon(Icons.message_rounded),
          label: Text('كتابة قالب الرسالة (${students.length})'),
        ),
      ),
    );
  }
}
