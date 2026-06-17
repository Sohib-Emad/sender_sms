import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/student.dart';
import 'bloc/preview_bloc.dart';
import 'bloc/preview_event.dart';
import 'bloc/preview_state.dart';

class DataPreviewScreen extends StatefulWidget {
  const DataPreviewScreen({super.key});

  @override
  State<DataPreviewScreen> createState() => _DataPreviewScreenState();
}

class _DataPreviewScreenState extends State<DataPreviewScreen> {
  final _searchController = TextEditingController();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dataPreview),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'إضافة طالب',
            onPressed: () => _showAddStudentDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<PreviewBloc, PreviewState>(
        builder: (context, state) {
          if (state is! PreviewLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: AppStrings.search,
                    hintTextDirection: TextDirection.rtl,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<PreviewBloc>()
                                  .add(const PreviewSearchChanged(''));
                            },
                          )
                        : null,
                  ),
                  onChanged: (query) {
                    context
                        .read<PreviewBloc>()
                        .add(PreviewSearchChanged(query));
                  },
                ),
              ),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'إجمالي: ${state.allStudents.length} طالب',
                      style: Theme.of(context).textTheme.bodySmall,
                      textDirection: TextDirection.rtl,
                    ),
                    if (state.filteredStudents.length !=
                        state.allStudents.length) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• معروض: ${state.filteredStudents.length}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.primary),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 1),

              // Students list
              Expanded(
                child: state.filteredStudents.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        itemCount: state.filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = state.filteredStudents[index];
                          return _StudentRow(
                            student: student,
                            index: index,
                            onEdit: () =>
                                _showEditStudentDialog(context, student),
                            onDelete: () =>
                                _confirmDelete(context, student),
                          );
                        },
                      ),
              ),

              // Bottom action
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: state.allStudents.isEmpty
                        ? null
                        : () {
                            context.push(
                              AppRouter.messageTemplate,
                              extra: state.allStudents,
                            );
                          },
                    icon: const Icon(Icons.message_rounded),
                    label: Text(
                        '${AppStrings.continueToTemplate} (${state.allStudents.length})'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('لا توجد نتائج', textDirection: TextDirection.rtl),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.deleteStudent,
            textDirection: TextDirection.rtl),
        content: Text('هل تريد حذف "${student.name}"؟',
            textDirection: TextDirection.rtl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<PreviewBloc>()
                  .add(PreviewDeleteStudent(student.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    _showStudentDialog(context, existingStudent: student);
  }

  void _showAddStudentDialog(BuildContext context) {
    _showStudentDialog(context);
  }

  void _showStudentDialog(BuildContext context, {Student? existingStudent}) {
    final nameController =
        TextEditingController(text: existingStudent?.name ?? '');
    final phoneController =
        TextEditingController(text: existingStudent?.phone ?? '');
    final degreeController =
        TextEditingController(text: existingStudent?.degree ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          existingStudent != null
              ? AppStrings.editStudent
              : AppStrings.addStudent,
          textDirection: TextDirection.rtl,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'اسم الطالب',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'مطلوب';
                  if (v.length < 8) return 'رقم غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: degreeController,
                decoration: const InputDecoration(
                  labelText: 'الدرجة',
                  prefixIcon: Icon(Icons.grade_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final student = Student(
                  id: existingStudent?.id ?? _uuid.v4(),
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  degree: degreeController.text.trim(),
                  createdAt: existingStudent?.createdAt ?? DateTime.now(),
                );
                if (existingStudent != null) {
                  context
                      .read<PreviewBloc>()
                      .add(PreviewUpdateStudent(student));
                } else {
                  context
                      .read<PreviewBloc>()
                      .add(PreviewAddStudent(student));
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(existingStudent != null ? 'حفظ' : 'إضافة'),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final Student student;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentRow({
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
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          '${index + 1}',
          style: TextStyle(
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              student.degree,
              style: TextStyle(
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
            icon: const Icon(Icons.delete_rounded,
                size: 20, color: AppColors.error),
            onPressed: onDelete,
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded,
                size: 20, color: AppColors.primary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
