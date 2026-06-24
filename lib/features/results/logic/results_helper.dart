import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/features/history/data/repos/sms_repository.dart';
import 'package:sender_sms/core/services/excel/excel_report_exporter.dart';

class ResultsHelper {
  static Future<String> exportReportPath(String sessionId) async {
    final repo = sl<SmsRepository>();
    final session = await repo.getSession(sessionId);
    final logs = await repo.getLogsBySession(sessionId);
    if (session == null) throw Exception('Session not found');
    return await ExcelReportExporter.exportReport(session: session, logs: logs);
  }

  static Future<void> handleExport(BuildContext context, String sessionId) async {
    try {
      final path = await exportReportPath(sessionId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تم تصدير التقرير بنجاح: $path', textDirection: TextDirection.rtl),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ: ${e.toString()}', textDirection: TextDirection.rtl),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  static Future<void> handleShare(BuildContext context, String sessionId) async {
    try {
      final path = await exportReportPath(sessionId);
      await Share.shareXFiles([XFile(path)], subject: 'تقرير إرسال SMS');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ: ${e.toString()}', textDirection: TextDirection.rtl),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}
