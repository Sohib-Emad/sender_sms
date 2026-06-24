import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class MessageTemplate extends HiveObject with EquatableMixin {
  final String id;
  final String name;
  final String content;
  final DateTime createdAt;
  final bool isDefault;

  MessageTemplate({
    required this.id,
    required this.name,
    required this.content,
    required this.createdAt,
    this.isDefault = false,
  });

  MessageTemplate copyWith({
    String? id,
    String? name,
    String? content,
    DateTime? createdAt,
    bool? isDefault,
  }) =>
      MessageTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        isDefault: isDefault ?? this.isDefault,
      );

  @override
  List<Object?> get props => [id, name, content, createdAt, isDefault];
}

class TemplateAdapter extends TypeAdapter<MessageTemplate> {
  @override
  final int typeId = 3;

  @override
  MessageTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      isDefault: (fields[4] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, MessageTemplate obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isDefault);
  }
}
