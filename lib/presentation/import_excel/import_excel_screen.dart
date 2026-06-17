import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import 'bloc/import_bloc.dart';
import 'bloc/import_event.dart';
import 'bloc/import_state.dart';

class ImportExcelScreen extends StatelessWidget {
  const ImportExcelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع ملف Excel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<ImportBloc, ImportState>(
        listener: (context, state) {
          if (state is ImportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, textDirection: TextDirection.rtl),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: _buildContent(context, state),
                  ),
                  if (state is ImportSuccess)
                    _buildContinueButton(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ImportState state) {
    if (state is ImportLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(AppStrings.readingFile, textDirection: TextDirection.rtl),
          ],
        ),
      );
    }

    if (state is ImportSuccess) {
      return _ImportSuccessContent(state: state);
    }

    return _ImportInitialContent();
  }

  Widget _buildContinueButton(BuildContext context, ImportSuccess state) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            context.push(AppRouter.dataPreview, extra: state.students);
          },
          icon: const Icon(Icons.visibility_rounded),
          label: const Text(AppStrings.continueToPreview),
        ),
      )
          .animate()
          .slideY(begin: 0.5, duration: 400.ms)
          .fadeIn(duration: 400.ms),
    );
  }
}

class _ImportInitialContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Instructions Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.requiredFormat,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                _FormatRow(label: 'الدرجة', example: '95', icon: Icons.grade_rounded),
                const SizedBox(height: 8),
                _FormatRow(
                    label: 'رقم الهاتف',
                    example: '201001112233',
                    icon: Icons.phone_rounded),
                const SizedBox(height: 8),
                _FormatRow(
                    label: 'اسم الطالب',
                    example: 'محمد أحمد',
                    icon: Icons.person_rounded),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'أسماء الأعمدة المقبولة: name, phone, degree',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 24),

        // Drop Zone
        Expanded(
          child: GestureDetector(
            onTap: () =>
                context.read<ImportBloc>().add(ImportPickFile()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 2,
                  // dashed effect approximation
                ),
                borderRadius: BorderRadius.circular(20),
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primaryLight.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(end: 1.1, duration: 1500.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.selectFile,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.selectFileSub,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textHint,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<ImportBloc>().add(ImportPickFile()),
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('اختيار الملف'),
                  ),
                ],
              ),
            ),
          ).animate().slideY(begin: 0.2, duration: 500.ms, delay: 200.ms).fadeIn(),
        ),
      ],
    );
  }
}

class _ImportSuccessContent extends StatelessWidget {
  final ImportSuccess state;
  const _ImportSuccessContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Success header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.successGradient,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${state.students.length} ${AppStrings.studentsFound}',
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
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 32),
              ),
            ],
          ),
        )
            .animate()
            .scale(duration: 400.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 300.ms),

        const SizedBox(height: 16),

        // Preview table
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
                        onPressed: () =>
                            context.read<ImportBloc>().add(ImportPickFile()),
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
                          AppColors.primary.withOpacity(0.1),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text('الدرجة',
                                textDirection: TextDirection.rtl),
                          ),
                          DataColumn(
                            label: Text('الهاتف',
                                textDirection: TextDirection.rtl),
                          ),
                          DataColumn(
                            label: Text('الاسم',
                                textDirection: TextDirection.rtl),
                          ),
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

class _FormatRow extends StatelessWidget {
  final String label;
  final String example;
  final IconData icon;

  const _FormatRow({
    required this.label,
    required this.example,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            example,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium,
            textDirection: TextDirection.rtl),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: AppColors.primary),
      ],
    );
  }
}
