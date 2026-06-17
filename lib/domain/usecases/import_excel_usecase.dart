import '../entities/student.dart';
import '../../data/datasources/excel/excel_service.dart';

class ImportExcelUseCase {
  Future<List<Student>> call(String filePath) async {
    return await ExcelService.importFromFile(filePath);
  }
}
