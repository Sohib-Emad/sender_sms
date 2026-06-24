import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class SmsSession extends HiveObject with EquatableMixin {
  final String id;
  final DateTime date;
  final int total;
  final int success;
  final int failed;
  final String templateUsed;
  final String status; // 'completed', 'cancelled', 'in_progress'

  SmsSession({
    required this.id,
    required this.date,
    required this.total,
    required this.success,
    required this.failed,
    required this.templateUsed,
    this.status = 'completed',
  });

  double get successRate => total == 0 ? 0 : (success / total * 100);

  SmsSession copyWith({
    String? id,
    DateTime? date,
    int? total,
    int? success,
    int? failed,
    String? templateUsed,
    String? status,
  }) =>
      SmsSession(
        id: id ?? this.id,
        date: date ?? this.date,
        total: total ?? this.total,
        success: success ?? this.success,
        failed: failed ?? this.failed,
        templateUsed: templateUsed ?? this.templateUsed,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props =>
      [id, date, total, success, failed, templateUsed, status];
}

class SmsSessionAdapter extends TypeAdapter<SmsSession> {
  @override
  final int typeId = 1;

  @override
  SmsSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsSession(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      total: fields[2] as int,
      success: fields[3] as int,
      failed: fields[4] as int,
      templateUsed: fields[5] as String,
      status: (fields[6] as String?) ?? 'completed',
    );
  }

  @override
  void write(BinaryWriter writer, SmsSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.total)
      ..writeByte(3)
      ..write(obj.success)
      ..writeByte(4)
      ..write(obj.failed)
      ..writeByte(5)
      ..write(obj.templateUsed)
      ..writeByte(6)
      ..write(obj.status);
  }
}
