import 'dart:io';
import 'package:excel/excel.dart';
import 'package:uuid/uuid.dart';
import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/core/utils/extensions.dart';

class ExcelReader {
  static const _uuid = Uuid();

  static Future<List<Student>> importFromFile(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    if (excel.sheets.keys.isEmpty) {
      throw Exception('لم يتم العثور على أوراق في ملف Excel');
    }

    final sheet = excel[excel.sheets.keys.first];
    final rows = sheet.rows;
    if (rows.isEmpty) throw Exception('ملف Excel فارغ - لا توجد بيانات');

    int nameCol = -1, phoneCol = -1, degreeCol = -1;
    final headerRow = rows.first;
    for (int i = 0; i < headerRow.length; i++) {
      final val = headerRow[i]?.value?.toString().toLowerCase().trim() ?? '';
      if (val == 'name' || val == 'الاسم' || val == 'اسم الطالب') {
        nameCol = i;
      } else if (val == 'phone' || val == 'الهاتف' || val == 'رقم الهاتف' || val == 'رقم ولي الأمر') {
        phoneCol = i;
      } else if (val == 'degree' || val == 'الدرجة' || val == 'الدرجات' || val == 'النتيجة') {
        degreeCol = i;
      }
    }

    final hasHeaders = nameCol != -1 || phoneCol != -1 || degreeCol != -1;
    final startRow = hasHeaders ? 1 : 0;
    if (!hasHeaders) {
      nameCol = 0;
      phoneCol = 1;
      degreeCol = 2;
    }

    final List<Student> students = [];
    for (int i = startRow; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final name = _getVal(row, nameCol);
      var phone = _getVal(row, phoneCol);
      final degree = _getVal(row, degreeCol);

      if (name.isEmpty && phone.isEmpty) continue;
      if (phone.isEmpty) continue;

      phone = phone.normalizeEgyptianPhone;

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

  static String _getVal(List<Data?> row, int col) {
    if (col < 0 || col >= row.length) return '';
    final cell = row[col];
    if (cell == null || cell.value == null) return '';
    var val = cell.value.toString().trim();
    if (val.endsWith('.0')) {
      val = val.substring(0, val.length - 2);
    }
    return val;
  }
}
