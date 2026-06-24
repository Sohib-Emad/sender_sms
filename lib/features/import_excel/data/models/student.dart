import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class Student extends HiveObject with EquatableMixin {
  final String id;
  final String name;
  final String phone;
  final String degree;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.degree,
    required this.createdAt,
  });

  Student copyWith({
    String? id,
    String? name,
    String? phone,
    String? degree,
    DateTime? createdAt,
  }) =>
      Student(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        degree: degree ?? this.degree,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, name, phone, degree, createdAt];
}

class StudentAdapter extends TypeAdapter<Student> {
  @override
  final int typeId = 0;

  @override
  Student read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Student(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      degree: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Student obj) {
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
