import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/message_template/logic/template_cubit.dart';

class SavedTemplatesTab extends StatelessWidget {
  final Function(String) onUseTemplate;
  const SavedTemplatesTab({super.key, required this.onUseTemplate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplateCubit, TemplateState>(
      builder: (context, state) {
        if (state is! TemplateLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final templates = state.templates;
        if (templates.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_rounded, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('لا توجد قوالب محفوظة', textDirection: TextDirection.rtl),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: templates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final tmpl = templates[i];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(tmpl.name, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    tmpl.content.length > 80 ? '${tmpl.content.substring(0, 80)}...' : tmpl.content,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                      onPressed: () => context.read<TemplateCubit>().delete(tmpl.id),
                    ),
                    ElevatedButton(
                      onPressed: () => onUseTemplate(tmpl.content),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      },
    );
  }
}
