import 'package:flutter/material.dart';

class EditorButtons extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onSend;
  final int studentCount;
  final bool canSend;

  const EditorButtons({
    super.key,
    required this.onSave,
    required this.onSend,
    required this.studentCount,
    required this.canSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('حفظ القالب'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: canSend ? onSend : null,
              icon: const Icon(Icons.send_rounded),
              label: Text('بدء الإرسال ($studentCount)'),
            ),
          ),
        ],
      ),
    );
  }
}
