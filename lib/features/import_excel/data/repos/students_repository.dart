import 'package:sender_sms/features/import_excel/data/models/student.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';

abstract class StudentsRepository {
  Future<List<Student>> getStudents();
  Future<void> saveStudents(List<Student> students);
  Future<void> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<void> clearAll();
}

class StudentsRepositoryImpl implements StudentsRepository {
  final HiveDatasource _datasource;
  StudentsRepositoryImpl(this._datasource);

  @override
  Future<List<Student>> getStudents() async => _datasource.getAllStudents();

  @override
  Future<void> saveStudents(List<Student> students) async =>
      _datasource.saveStudents(students);

  @override
  Future<void> addStudent(Student student) async => _datasource.addStudent(student);

  @override
  Future<void> updateStudent(Student student) async =>
      _datasource.updateStudent(student);

  @override
  Future<void> deleteStudent(String id) async => _datasource.deleteStudent(id);

  @override
  Future<void> clearAll() async => _datasource.clearStudents();
}
