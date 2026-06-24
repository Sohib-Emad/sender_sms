import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';

class SendReadyState extends StatelessWidget {
  final List<Student> students;
  final String template;
  final bool isRequesting;

  const SendReadyState({
    super.key,
    required this.students,
    required this.template,
    required this.isRequesting,
  });

  @override
  Widget build(BuildContext context) {
    final previewMsg = students.isNotEmpty
        ? template
            .replaceAll('{name}', students.first.name)
            .replaceAll('{degree}', students.first.degree)
            .replaceAll('{phone}', students.first.phone)
        : template;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.send_rounded, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'جاهز للإرسال',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${students.length} رسالة ستُرسل',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms).fadeIn(),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      ScreenStrings.previewMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.preview_rounded, size: 18, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  previewMsg,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 200.ms).fadeIn(),
        if (isRequesting)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(ScreenStrings.requestingPermissions, textDirection: TextDirection.rtl),
              ],
            ),
          ),
      ],
    );
  }
}
