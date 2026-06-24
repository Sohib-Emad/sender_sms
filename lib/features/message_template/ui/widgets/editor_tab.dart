import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'variables_section.dart';
import 'editor_preview.dart';
import 'editor_buttons.dart';

class EditorTab extends StatelessWidget {
  final TextEditingController contentController;
  final int charCount;
  final int smsParts;
  final String previewMessage;
  final List<Student> students;
  final VoidCallback onSave;
  final VoidCallback onSend;

  const EditorTab({
    super.key,
    required this.contentController,
    required this.charCount,
    required this.smsParts,
    required this.previewMessage,
    required this.students,
    required this.onSave,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                VariablesSection(onVariableInsert: (v) {
                  final text = contentController.text;
                  final sel = contentController.selection;
                  final newText = text.replaceRange(
                    sel.start >= 0 ? sel.start : text.length,
                    sel.end >= 0 ? sel.end : text.length,
                    v,
                  );
                  contentController.text = newText;
                }),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 6,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'اكتب قالب الرسالة...',
                    hintTextDirection: TextDirection.rtl,
                    labelText: 'نص الرسالة',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: smsParts > 1
                            ? AppColors.warning.withValues(alpha: 0.15)
                            : AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'أجزاء SMS: $smsParts',
                        style: TextStyle(
                          color: smsParts > 1 ? AppColors.warning : AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text('$charCount عدد الأحرف', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                if (contentController.text.isNotEmpty)
                  EditorPreview(previewMessage: previewMessage),
              ],
            ),
          ),
        ),
        EditorButtons(
          onSave: onSave,
          onSend: onSend,
          studentCount: students.length,
          canSend: contentController.text.isNotEmpty,
        ),
      ],
    );
  }
}
