import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/message_template.dart';
import '../../domain/entities/student.dart';
import 'bloc/template_bloc.dart';
import 'bloc/template_event.dart';
import 'bloc/template_state.dart';

class MessageTemplateScreen extends StatefulWidget {
  final List<Student> students;
  const MessageTemplateScreen({super.key, required this.students});

  @override
  State<MessageTemplateScreen> createState() => _MessageTemplateScreenState();
}

class _MessageTemplateScreenState extends State<MessageTemplateScreen>
    with SingleTickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _nameController = TextEditingController(text: 'القالب الجديد');
  late TabController _tabController;
  static const _uuid = Uuid();

  static const String _defaultTemplate =
      'السيد ولي الأمر الكريم،\n\nنحيطكم علماً بأن درجة الطالب {name}\n\nهي: {degree}\n\nمع تحيات إدارة المدرسة';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _contentController.text = _defaultTemplate;
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
  int get _smsParts {
    if (_charCount <= 70) return 1;
    return (_charCount / 67).ceil();
  }

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
        title: const Text(AppStrings.messageTemplate),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'تعديل'),
            Tab(text: 'قوالب محفوظة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditorTab(),
          _buildSavedTemplatesTab(),
        ],
      ),
    );
  }

  Widget _buildEditorTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Variables chips
                _VariablesSection(
                  onVariableInsert: (variable) {
                    final text = _contentController.text;
                    final selection = _contentController.selection;
                    final newText = text.replaceRange(
                      selection.start >= 0 ? selection.start : text.length,
                      selection.end >= 0 ? selection.end : text.length,
                      variable,
                    );
                    _contentController.text = newText;
                  },
                ),
                const SizedBox(height: 16),

                // Template editor
                TextField(
                  controller: _contentController,
                  maxLines: 8,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: AppStrings.writeTemplate,
                    hintTextDirection: TextDirection.rtl,
                    alignLabelWithHint: true,
                    labelText: 'نص الرسالة',
                  ),
                ),
                const SizedBox(height: 12),

                // Char count + SMS parts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _smsParts > 1
                            ? AppColors.warning.withOpacity(0.15)
                            : AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${AppStrings.smsPartCount}: $_smsParts',
                        style: TextStyle(
                          color: _smsParts > 1
                              ? AppColors.warning
                              : AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '$_charCount ${AppStrings.charCount}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preview card
                if (_contentController.text.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(AppStrings.previewMessage,
                          style: Theme.of(context).textTheme.titleMedium,
                          textDirection: TextDirection.rtl),
                      const SizedBox(width: 8),
                      const Icon(Icons.preview_rounded,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      _previewMessage,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Bottom actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveTemplate,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text('حفظ القالب'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _contentController.text.isEmpty
                          ? null
                          : _startSending,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                          '${AppStrings.startSending} (${widget.students.length})'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavedTemplatesTab() {
    return BlocBuilder<TemplateBloc, TemplateState>(
      builder: (context, state) {
        if (state is TemplateLoaded) {
          if (state.templates.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_rounded,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('لا توجد قوالب محفوظة',
                      textDirection: TextDirection.rtl),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final tmpl = state.templates[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(tmpl.name,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      tmpl.content.length > 80
                          ? '${tmpl.content.substring(0, 80)}...'
                          : tmpl.content,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_rounded,
                            size: 18, color: AppColors.error),
                        onPressed: () => context
                            .read<TemplateBloc>()
                            .add(TemplateDelete(tmpl.id)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _contentController.text = tmpl.content;
                          _tabController.animateTo(0);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                        child: const Text('استخدام'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _saveTemplate() {
    final template = MessageTemplate(
      id: _uuid.v4(),
      name: _nameController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
    );
    context.read<TemplateBloc>().add(TemplateSave(template));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ القالب', textDirection: TextDirection.rtl),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _startSending() {
    if (_contentController.text.isEmpty) return;
    context.push(
      AppRouter.sendSms,
      extra: {
        'students': widget.students,
        'template': _contentController.text,
      },
    );
  }
}

class _VariablesSection extends StatelessWidget {
  final void Function(String) onVariableInsert;

  const _VariablesSection({required this.onVariableInsert});

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
          AppStrings.variables,
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
              label: Text('${v.$1} ${v.$2}',
                  textDirection: TextDirection.rtl),
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
