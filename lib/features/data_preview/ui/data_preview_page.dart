import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/features/data_preview/logic/preview_cubit.dart';

import 'widgets/delete_confirm_dialog.dart';
import 'widgets/preview_bottom_action.dart';
import 'widgets/preview_search_bar.dart';
import 'widgets/preview_stats_row.dart';
import 'widgets/student_dialog.dart';
import 'widgets/student_row.dart';

class DataPreviewPage extends StatefulWidget {
  const DataPreviewPage({super.key});

  @override
  State<DataPreviewPage> createState() => _DataPreviewPageState();
}

class _DataPreviewPageState extends State<DataPreviewPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة البيانات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () => _showDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<PreviewCubit, PreviewState>(
        builder: (context, state) {
          if (state is! PreviewLoaded) return const Center(child: CircularProgressIndicator());

          return Column(
            children: [
              PreviewSearchBar(
                controller: _searchController,
                onChanged: (q) => context.read<PreviewCubit>().search(q),
                onClear: () {
                  _searchController.clear();
                  context.read<PreviewCubit>().search('');
                },
              ),
              PreviewStatsRow(
                totalCount: state.allStudents.length,
                filteredCount: state.filteredStudents.length,
              ),
              const Divider(height: 1),
              Expanded(
                child: state.filteredStudents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('لا توجد نتائج', textDirection: TextDirection.rtl),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.filteredStudents.length,
                        itemBuilder: (c, idx) {
                          final student = state.filteredStudents[idx];
                          return StudentRow(
                            student: student,
                            index: idx,
                            onEdit: () => _showDialog(context, existing: student),
                            onDelete: () => _confirmDelete(context, student),
                          );
                        },
                      ),
              ),
              PreviewBottomAction(students: state.allStudents),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog<bool>(context: context, builder: (_) => DeleteConfirmDialog(student: student))
        .then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<PreviewCubit>().delete(student.id);
      }
    });
  }

  void _showDialog(BuildContext context, {Student? existing}) {
    showDialog(
      context: context,
      builder: (_) => StudentDialog(
        existingStudent: existing,
        onSave: (s) => existing != null
            ? context.read<PreviewCubit>().updateStudent(s)
            : context.read<PreviewCubit>().addStudent(s),
      ),
    );
  }
}
