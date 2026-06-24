import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';
import 'package:sender_sms/core/utils/extensions.dart';
import 'package:sender_sms/core/services/excel/excel_template.dart';
import 'package:sender_sms/features/import_excel/logic/import_cubit.dart';
import 'format_row.dart';

class ImportInitialContent extends StatelessWidget {
  const ImportInitialContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                      ScreenStrings.requiredFormat,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                const FormatRow(label: 'الدرجة', example: '95', icon: Icons.grade_rounded),
                const SizedBox(height: 8),
                const FormatRow(label: 'رقم الهاتف', example: '01001112233', icon: Icons.phone_rounded),
                const SizedBox(height: 8),
                const FormatRow(label: 'اسم الطالب', example: 'محمد أحمد', icon: Icons.person_rounded),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'أسماء الأعمدة المقبولة: name, phone, degree',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _downloadTemplate(context),
            icon: const Icon(Icons.download_rounded),
            label: const Text('تحميل نموذج Excel'),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<ImportCubit>().pickFile(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
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
                    child: const Icon(Icons.upload_file_rounded, size: 56, color: AppColors.primary),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scaleXY(end: 1.1, duration: 1500.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 20),
                  Text(
                    ScreenStrings.selectFile,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ScreenStrings.selectFileSub,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context.read<ImportCubit>().pickFile(),
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

  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      final path = await ExcelTemplate.generateTemplate();
      await Share.shareXFiles([XFile(path)], subject: 'نموذج إرسال SMS');
    } catch (e) {
      if (context.mounted) {
        context.showSnack('فشل تحميل النموذج: ${e.toString()}', isError: true);
      }
    }
  }
}
