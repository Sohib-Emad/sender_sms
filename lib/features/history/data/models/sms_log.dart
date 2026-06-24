import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class SmsLog extends HiveObject with EquatableMixin {
  final String id;
  final String sessionId;
  final String studentName;
  final String phone;
  final String message;
  final String status; // 'sent', 'failed', 'pending'
  final String? errorMessage;
  final DateTime sentAt;

  SmsLog({
    required this.id,
    required this.sessionId,
    required this.studentName,
    required this.phone,
    required this.message,
    required this.status,
    this.errorMessage,
    required this.sentAt,
  });

  bool get isSent => status == 'sent';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';

  SmsLog copyWith({
    String? id,
    String? sessionId,
    String? studentName,
    String? phone,
    String? message,
    String? status,
    String? errorMessage,
    DateTime? sentAt,
  }) =>
      SmsLog(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        studentName: studentName ?? this.studentName,
        phone: phone ?? this.phone,
        message: message ?? this.message,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        sentAt: sentAt ?? this.sentAt,
      );

  @override
  List<Object?> get props =>
      [id, sessionId, studentName, phone, message, status, errorMessage, sentAt];
}

class SmsLogAdapter extends TypeAdapter<SmsLog> {
  @override
  final int typeId = 2;

  @override
  SmsLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsLog(
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
  void write(BinaryWriter writer, SmsLog obj) {
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
