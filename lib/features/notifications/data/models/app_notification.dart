import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class AppNotification extends HiveObject with EquatableMixin {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
  }) =>
      AppNotification(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
      );

  @override
  List<Object?> get props => [id, title, body, timestamp, isRead];
}

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 4;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      timestamp: fields[3] as DateTime,
      isRead: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.isRead);
  }
}
