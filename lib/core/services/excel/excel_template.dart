import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ExcelTemplate {
  static Future<String> generateTemplate() async {
    final excel = Excel.createExcel();
    final sheet = excel[excel.sheets.keys.first];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1A73E8'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    _setCell(sheet, 0, 0, 'name', headerStyle);
    _setCell(sheet, 0, 1, 'phone', headerStyle);
    _setCell(sheet, 0, 2, 'degree', headerStyle);

    final names = ['أحمد', 'محمد', 'سارة', 'عمر', 'نور', 'يوسف', 'مريم', 'خالد'];
    final families = ['محمد', 'علي', 'خالد', 'حسن', 'سليمان', 'عبدالله'];

    for (int i = 0; i < 20; i++) {
      final name = names[i % names.length];
      final family = families[(i * 7) % families.length];
      final fullName = '$name $family';
      final phone = '01${(100000000 + i * 11111) % 900000000 + 100000000}';
      final degree = '${50 + (i * 7) % 51}';
      _setCell(sheet, i + 1, 0, fullName, null);
      _setCell(sheet, i + 1, 1, phone, null);
      _setCell(sheet, i + 1, 2, degree, null);
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'SMS_Template_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
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
