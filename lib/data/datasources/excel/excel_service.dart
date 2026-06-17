import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/sms_session.dart';
import '../../../domain/entities/sms_log.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ExcelService {
  static const _uuid = Uuid();

  /// Import students from Excel file
  /// Expected columns: name, phone, degree (in any order, or columns 0,1,2)
  static Future<List<Student>> importFromFile(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    List<Student> students = [];

    // Get first sheet
    final sheetNames = excel.sheets.keys.toList();
    if (sheetNames.isEmpty) {
      throw Exception('لم يتم العثور على أوراق في ملف Excel');
    }
    final sheet = excel[sheetNames.first];
    final rows = sheet.rows;

    if (rows.isEmpty) {
      throw Exception('ملف Excel فارغ - لا توجد بيانات');
    }

    // Detect header row
    int nameCol = -1, phoneCol = -1, degreeCol = -1;
    final headerRow = rows.first;

    for (int i = 0; i < headerRow.length; i++) {
      final cell = headerRow[i];
      final value = cell?.value?.toString().toLowerCase().trim() ?? '';
      if (value == 'name' || value == 'الاسم' || value == 'اسم الطالب') {
        nameCol = i;
      } else if (value == 'phone' ||
          value == 'الهاتف' ||
          value == 'رقم الهاتف' ||
          value == 'رقم ولي الأمر') {
        phoneCol = i;
      } else if (value == 'degree' ||
          value == 'الدرجة' ||
          value == 'الدرجات' ||
          value == 'النتيجة') {
        degreeCol = i;
      }
    }

    // Default to columns 0, 1, 2 if headers not found
    final hasHeaders = nameCol != -1 || phoneCol != -1 || degreeCol != -1;
    final startRow = hasHeaders ? 1 : 0;
    if (!hasHeaders) {
      nameCol = 0;
      phoneCol = 1;
      degreeCol = 2;
    }

    for (int i = startRow; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final name = _getCellValue(row, nameCol);
      final phone = _getCellValue(row, phoneCol);
      final degree = _getCellValue(row, degreeCol);

      if (name.isEmpty && phone.isEmpty) continue;
      if (phone.isEmpty) continue;

      students.add(Student(
        id: _uuid.v4(),
        name: name.isNotEmpty ? name : 'غير محدد',
        phone: phone,
        degree: degree.isNotEmpty ? degree : '0',
        createdAt: DateTime.now(),
      ));
    }

    return students;
  }

  static String _getCellValue(List<Data?> row, int col) {
    if (col < 0 || col >= row.length) return '';
    final cell = row[col];
    return cell?.value?.toString().trim() ?? '';
  }

  /// Generate an empty template file with headers: name, phone, degree
  static Future<String> generateTemplate() async {
    final excel = Excel.createExcel();
    final sheetName = excel.sheets.keys.first;
    final sheet = excel[sheetName];

    _setCell(sheet, 0, 0, 'name', _headerStyle(excel));
    _setCell(sheet, 0, 1, 'phone', _headerStyle(excel));
    _setCell(sheet, 0, 2, 'degree', _headerStyle(excel));

    final names = [
      'أحمد', 'محمد', 'سارة', 'عمر', 'نور', 'يوسف', 'مريم', 'خالد', 'لينا', 'علي',
      'هدى', 'آدم', 'سلمى', 'كريم', 'دينا', 'حسن', 'فاطمة', 'محمود', 'رنا', 'أمير',
      'ندى', 'بسام', 'هاجر', 'إبراهيم', 'سحر', 'زياد', 'منى', 'أسامة', 'رهام', 'عبدالله',
      'هند', 'جمال', 'نها', 'طارق', 'غادة', 'مصطفى', 'إيمان', 'عمرو', 'سماح', 'ناصر',
      'شيماء', 'وائل', 'مها', 'عادل', 'نجوى', 'باسم', 'إيناس', 'رامي', 'نهى', 'سامي',
    ];
    final families = [
      'محمد', 'علي', 'خالد', 'حسن', 'سليمان', 'عبدالله', 'صالح', 'رضا', 'إبراهيم',
      'أحمد', 'ناصر', 'جمال', 'طارق', 'عادل', 'مصطفى', 'عمرو', 'رامي', 'سامي', 'وائل',
      'بسام', 'زياد', 'أسامة', 'كمال', 'شريف', 'هاني', 'ماجد', 'وليد', 'أيمن', 'فؤاد',
    ];
    for (int i = 0; i < 100; i++) {
      final name = names[i % names.length];
      final family = families[(i * 7) % families.length];
      final fullName = '$name $family';
      final phone = '201${(100000000 + i * 11111) % 900000000 + 100000000}';
      final degree = '${50 + (i * 7) % 51}';
      _setCell(sheet, i + 1, 0, fullName, null);
      _setCell(sheet, i + 1, 1, phone, null);
      _setCell(sheet, i + 1, 2, degree, null);
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'SMS_Template_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${dir.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath).writeAsBytesSync(fileBytes);
    }

    return filePath;
  }

  static CellStyle? _headerStyle(Excel excel) {
    return CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1A73E8'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
  }

  /// Export session results to Excel and return file path
  static Future<String> exportReport({
    required SmsSession session,
    required List<SmsLog> logs,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['نتائج الإرسال'];

    // Header
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

    // Data rows
    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final row = i + 1;
      _setCell(sheet, row, 0, log.studentName, null);
      _setCell(sheet, row, 1, log.phone, null);
      _setCell(sheet, row, 2, log.message, null);
      _setCell(
          sheet, row, 3, log.isSent ? 'مرسل ✓' : 'فاشل ✗', null);
      _setCell(
          sheet,
          row,
          4,
          DateFormat('dd/MM/yyyy HH:mm').format(log.sentAt),
          null);
      _setCell(sheet, row, 5, log.errorMessage ?? '', null);
    }

    // Summary sheet
    final summarySheet = excel['ملخص'];
    _setCell(summarySheet, 0, 0, 'إجمالي الرسائل', null);
    _setCell(summarySheet, 0, 1, session.total.toString(), null);
    _setCell(summarySheet, 1, 0, 'تم الإرسال', null);
    _setCell(summarySheet, 1, 1, session.success.toString(), null);
    _setCell(summarySheet, 2, 0, 'فشل الإرسال', null);
    _setCell(summarySheet, 2, 1, session.failed.toString(), null);
    _setCell(summarySheet, 3, 0, 'نسبة النجاح', null);
    _setCell(summarySheet, 3, 1,
        '${session.successRate.toStringAsFixed(1)}%', null);
    _setCell(summarySheet, 4, 0, 'التاريخ', null);
    _setCell(summarySheet, 4, 1,
        DateFormat('dd/MM/yyyy').format(session.date), null);

    // Save file
    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final fileName =
        'SMS_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final filePath = '${dir.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath).writeAsBytesSync(fileBytes);
    }

    return filePath;
  }

  static void _setCell(
      Sheet sheet, int row, int col, String value, CellStyle? style) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(
      columnIndex: col,
      rowIndex: row,
    ));
    cell.value = TextCellValue(value);
    if (style != null) cell.cellStyle = style;
  }
}
