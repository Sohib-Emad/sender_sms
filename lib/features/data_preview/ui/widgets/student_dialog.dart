import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sender_sms/core/constants/app_strings.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';

class StudentDialog extends StatefulWidget {
  final Student? existingStudent;
  final Function(Student) onSave;

  const StudentDialog({super.key, this.existingStudent, required this.onSave});

  @override
  State<StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends State<StudentDialog> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.existingStudent?.name ?? '');
  late final TextEditingController _phoneController =
      TextEditingController(text: widget.existingStudent?.phone ?? '');
  late final TextEditingController _degreeController =
      TextEditingController(text: widget.existingStudent?.degree ?? '');
  final _formKey = GlobalKey<FormState>();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _degreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingStudent != null ? ScreenStrings.editStudent : ScreenStrings.addStudent,
        textDirection: TextDirection.rtl,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                    labelText: 'اسم الطالب', prefixIcon: Icon(Icons.person_rounded)),
                validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_rounded)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'مطلوب';
                  if (v.length < 8) return 'رقم غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(
                    labelText: 'الدرجة', prefixIcon: Icon(Icons.grade_rounded)),
                validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final student = Student(
                id: widget.existingStudent?.id ?? _uuid.v4(),
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                degree: _degreeController.text.trim(),
                createdAt: widget.existingStudent?.createdAt ?? DateTime.now(),
              );
              widget.onSave(student);
              Navigator.pop(context);
            }
          },
          child: Text(widget.existingStudent != null ? 'حفظ' : 'إضافة'),
        ),
      ],
    );
  }
}
