import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';
import 'package:sender_sms/features/import_excel/logic/import_cubit.dart';

class ImportSuccessContent extends StatelessWidget {
  final ImportSuccess state;
  const ImportSuccessContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.successGradient),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${state.students.length} ${ScreenStrings.studentsFound}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.fileName,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
        )
            .animate()
            .scale(duration: 400.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 300.ms),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.read<ImportCubit>().pickFile(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('تغيير الملف'),
                      ),
                      Text(
                        'معاينة البيانات',
                        style: Theme.of(context).textTheme.titleMedium,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.primary.withValues(alpha: 0.1),
                        ),
                        columns: const [
                          DataColumn(label: Text('الدرجة')),
                          DataColumn(label: Text('الهاتف')),
                          DataColumn(label: Text('الاسم')),
                        ],
                        rows: state.students
                            .take(10)
                            .map(
                              (s) => DataRow(
                                cells: [
                                  DataCell(Text(s.degree)),
                                  DataCell(Text(s.phone)),
                                  DataCell(Text(s.name,
                                      textDirection: TextDirection.rtl)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
                if (state.students.length > 10)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '... و ${state.students.length - 10} طالب آخرون',
                      style: Theme.of(context).textTheme.bodySmall,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
