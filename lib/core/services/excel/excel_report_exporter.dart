import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:sender_sms/features/history/data/models/sms_session.dart';
import 'package:sender_sms/features/history/data/models/sms_log.dart';

class ExcelReportExporter {
  static Future<String> exportReport({
    required SmsSession session,
    required List<SmsLog> logs,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['نتائج الإرسال'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1A73E8'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    _setCell(sheet, 0, 0, 'اسم الطالب', headerStyle);
    _setCell(sheet, 0, 1, 'رقم الهاتف', headerStyle);
    _setCell(sheet, 0, 2, 'الرسالة', headerStyle);
    _setCell(sheet, 0, 3, 'الحالة', headerStyle);
    _setCell(sheet, 0, 4, 'وقت الإرسال', headerStyle);
    _setCell(sheet, 0, 5, 'سبب الفشل', headerStyle);

    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final row = i + 1;
      _setCell(sheet, row, 0, log.studentName, null);
      _setCell(sheet, row, 1, log.phone, null);
      _setCell(sheet, row, 2, log.message, null);
      _setCell(sheet, row, 3, log.isSent ? 'مرسل ✓' : 'فاشل ✗', null);
      _setCell(sheet, row, 4, DateFormat('dd/MM/yyyy HH:mm').format(log.sentAt), null);
      _setCell(sheet, row, 5, log.errorMessage ?? '', null);
    }

    final summarySheet = excel['ملخص'];
    _setCell(summarySheet, 0, 0, 'إجمالي الرسائل', null);
    _setCell(summarySheet, 0, 1, session.total.toString(), null);
    _setCell(summarySheet, 1, 0, 'تم الإرسال', null);
    _setCell(summarySheet, 1, 1, session.success.toString(), null);
    _setCell(summarySheet, 2, 0, 'فشل الإرسال', null);
    _setCell(summarySheet, 2, 1, session.failed.toString(), null);
    _setCell(summarySheet, 3, 0, 'نسبة النجاح', null);
    _setCell(summarySheet, 3, 1, '${session.successRate.toStringAsFixed(1)}%', null);
    _setCell(summarySheet, 4, 0, 'التاريخ', null);
    _setCell(summarySheet, 4, 1, DateFormat('dd/MM/yyyy').format(session.date), null);

    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final fileName = 'SMS_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${dir.path}/$fileName';

    final bytes = excel.save();
    if (bytes != null) File(filePath).writeAsBytesSync(bytes);

    return filePath;
  }

  static void _setCell(Sheet sheet, int row, int col, String value, CellStyle? style) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value);
    if (style != null) cell.cellStyle = style;
  }
}
