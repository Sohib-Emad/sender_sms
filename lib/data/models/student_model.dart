import 'package:hive/hive.dart';
import '../../domain/entities/student.dart';

class StudentModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late String degree;

  @HiveField(4)
  late DateTime createdAt;

  StudentModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.degree,
    required this.createdAt,
  });

  factory StudentModel.fromEntity(Student entity) => StudentModel(
        id: entity.id,
        name: entity.name,
        phone: entity.phone,
        degree: entity.degree,
        createdAt: entity.createdAt,
      );

  Student toEntity() => Student(
        id: id,
        name: name,
        phone: phone,
        degree: degree,
        createdAt: createdAt,
      );
}

class StudentAdapter extends TypeAdapter<StudentModel> {
  @override
  final int typeId = 0;

  @override
  StudentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudentModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      degree: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.degree)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}
