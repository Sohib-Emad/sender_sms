import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/message_template/data/models/message_template.dart';
import 'package:sender_sms/features/message_template/logic/template_cubit.dart';

import 'widgets/editor_tab.dart';
import 'widgets/saved_templates_tab.dart';

class MessageTemplatePage extends StatefulWidget {
  final List<Student> students;
  const MessageTemplatePage({super.key, required this.students});

  @override
  State<MessageTemplatePage> createState() => _MessageTemplatePageState();
}

class _MessageTemplatePageState extends State<MessageTemplatePage>
    with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _nameController = TextEditingController(text: 'القالب الجديد');
  late TabController _tabController;
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _contentController.text =
        'السيد ولي الأمر الكريم،\n\nنحيطكم علماً بأن درجة الطالب {name}\n\nهي: {degree}\n\nمع تحيات إدارة المدرسة';
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _contentController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  int get _charCount => _contentController.text.length;
  int get _smsParts => _charCount <= 70 ? 1 : (_charCount / 67).ceil();

  String get _previewMessage {
    if (widget.students.isEmpty) return _contentController.text;
    final s = widget.students.first;
    return _contentController.text
        .replaceAll('{name}', s.name)
        .replaceAll('{degree}', s.degree)
        .replaceAll('{phone}', s.phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قالب الرسالة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'تعديل'), Tab(text: 'قوالب محفوظة')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EditorTab(
            contentController: _contentController,
            charCount: _charCount,
            smsParts: _smsParts,
            previewMessage: _previewMessage,
            students: widget.students,
            onSave: _saveTemplate,
            onSend: _startSending,
          ),
          SavedTemplatesTab(onUseTemplate: (c) {
            _contentController.text = c;
            _tabController.animateTo(0);
          }),
        ],
      ),
    );
  }

  void _saveTemplate() {
    final template = MessageTemplate(
      id: _uuid.v4(),
      name: _nameController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
    );
    context.read<TemplateCubit>().save(template);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تم حفظ القالب', textDirection: TextDirection.rtl),
      backgroundColor: AppColors.success,
    ));
  }

  void _startSending() {
    context.push(AppRoutes.sendSms, extra: {
      'students': widget.students,
      'template': _contentController.text,
    });
  }
}
