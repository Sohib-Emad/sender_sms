import 'package:hive/hive.dart';
import '../../domain/entities/sms_session.dart';

class SmsSessionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late int total;

  @HiveField(3)
  late int success;

  @HiveField(4)
  late int failed;

  @HiveField(5)
  late String templateUsed;

  @HiveField(6)
  late String status;

  SmsSessionModel({
    required this.id,
    required this.date,
    required this.total,
    required this.success,
    required this.failed,
    required this.templateUsed,
    this.status = 'completed',
  });

  factory SmsSessionModel.fromEntity(SmsSession entity) => SmsSessionModel(
        id: entity.id,
        date: entity.date,
        total: entity.total,
        success: entity.success,
        failed: entity.failed,
        templateUsed: entity.templateUsed,
        status: entity.status,
      );

  SmsSession toEntity() => SmsSession(
        id: id,
        date: date,
        total: total,
        success: success,
        failed: failed,
        templateUsed: templateUsed,
        status: status,
      );
}

class SmsSessionAdapter extends TypeAdapter<SmsSessionModel> {
  @override
  final int typeId = 1;

  @override
  SmsSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsSessionModel(
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
  void write(BinaryWriter writer, SmsSessionModel obj) {
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
