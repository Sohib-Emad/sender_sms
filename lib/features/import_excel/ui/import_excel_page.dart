import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/import_excel/logic/import_cubit.dart';
import 'widgets/import_initial_content.dart';
import 'widgets/import_success_content.dart';

class ImportExcelPage extends StatelessWidget {
  const ImportExcelPage({super.key});

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
      body: BlocConsumer<ImportCubit, ImportState>(
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
                  if (state is ImportSuccess) _buildContinueButton(context, state),
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
            Text(ScreenStrings.readingFile, textDirection: TextDirection.rtl),
          ],
        ),
      );
    }
    if (state is ImportSuccess) {
      return ImportSuccessContent(state: state);
    }
    return const ImportInitialContent();
  }

  Widget _buildContinueButton(BuildContext context, ImportSuccess state) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => context.push(AppRoutes.dataPreview, extra: state.students),
          icon: const Icon(Icons.visibility_rounded),
          label: const Text(ScreenStrings.continueToPreview),
        ),
      ).animate().slideY(begin: 0.5, duration: 400.ms).fadeIn(duration: 400.ms),
    );
  }
}
