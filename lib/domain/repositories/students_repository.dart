import '../../domain/entities/student.dart';

abstract class StudentsRepository {
  Future<List<Student>> getStudents();
  Future<void> saveStudents(List<Student> students);
  Future<void> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<void> clearAll();
}
