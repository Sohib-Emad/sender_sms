import '../../domain/entities/student.dart';
import '../../domain/repositories/students_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/student_model.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  final HiveDatasource _datasource;

  StudentsRepositoryImpl(this._datasource);

  @override
  Future<List<Student>> getStudents() async {
    return _datasource.getAllStudents().map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveStudents(List<Student> students) async {
    final models = students.map(StudentModel.fromEntity).toList();
    await _datasource.saveStudents(models);
  }

  @override
  Future<void> addStudent(Student student) async {
    await _datasource.addStudent(StudentModel.fromEntity(student));
  }

  @override
  Future<void> updateStudent(Student student) async {
    await _datasource.updateStudent(StudentModel.fromEntity(student));
  }

  @override
  Future<void> deleteStudent(String id) async {
    await _datasource.deleteStudent(id);
  }

  @override
  Future<void> clearAll() async {
    await _datasource.clearStudents();
  }
}
