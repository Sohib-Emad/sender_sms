import 'package:hive/hive.dart';
import '../../domain/entities/message_template.dart';

class TemplateModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String content;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late bool isDefault;

  TemplateModel({
    required this.id,
    required this.name,
    required this.content,
    required this.createdAt,
    this.isDefault = false,
  });

  factory TemplateModel.fromEntity(MessageTemplate entity) => TemplateModel(
        id: entity.id,
        name: entity.name,
        content: entity.content,
        createdAt: entity.createdAt,
        isDefault: entity.isDefault,
      );

  MessageTemplate toEntity() => MessageTemplate(
        id: id,
        name: name,
        content: content,
        createdAt: createdAt,
        isDefault: isDefault,
      );
}

class TemplateAdapter extends TypeAdapter<TemplateModel> {
  @override
  final int typeId = 3;

  @override
  TemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateModel(
      id: fields[0] as String,
      name: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      isDefault: (fields[4] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateModel obj) {
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
