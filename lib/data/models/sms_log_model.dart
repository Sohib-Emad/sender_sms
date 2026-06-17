import 'package:hive/hive.dart';
import '../../domain/entities/sms_log.dart';

class SmsLogModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String sessionId;

  @HiveField(2)
  late String studentName;

  @HiveField(3)
  late String phone;

  @HiveField(4)
  late String message;

  @HiveField(5)
  late String status;

  @HiveField(6)
  String? errorMessage;

  @HiveField(7)
  late DateTime sentAt;

  SmsLogModel({
    required this.id,
    required this.sessionId,
    required this.studentName,
    required this.phone,
    required this.message,
    required this.status,
    this.errorMessage,
    required this.sentAt,
  });

  factory SmsLogModel.fromEntity(SmsLog entity) => SmsLogModel(
        id: entity.id,
        sessionId: entity.sessionId,
        studentName: entity.studentName,
        phone: entity.phone,
        message: entity.message,
        status: entity.status,
        errorMessage: entity.errorMessage,
        sentAt: entity.sentAt,
      );

  SmsLog toEntity() => SmsLog(
        id: id,
        sessionId: sessionId,
        studentName: studentName,
        phone: phone,
        message: message,
        status: status,
        errorMessage: errorMessage,
        sentAt: sentAt,
      );
}

class SmsLogAdapter extends TypeAdapter<SmsLogModel> {
  @override
  final int typeId = 2;

  @override
  SmsLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsLogModel(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      studentName: fields[2] as String,
      phone: fields[3] as String,
      message: fields[4] as String,
      status: fields[5] as String,
      errorMessage: fields[6] as String?,
      sentAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SmsLogModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.studentName)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.errorMessage)
      ..writeByte(7)
      ..write(obj.sentAt);
  }
}
