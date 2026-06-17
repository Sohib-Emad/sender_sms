class MessageTemplate {
  final String id;
  final String name;
  final String content;
  final DateTime createdAt;
  final bool isDefault;

  const MessageTemplate({
    required this.id,
    required this.name,
    required this.content,
    required this.createdAt,
    this.isDefault = false,
  });

  /// Build the actual message by replacing placeholders
  String buildMessage({
    required String studentName,
    required String degree,
    required String phone,
  }) {
    return content
        .replaceAll('{name}', studentName)
        .replaceAll('{degree}', degree)
        .replaceAll('{phone}', phone);
  }

  /// Count the number of SMS parts (160 chars per SMS in Arabic = 70 chars)
  int get smsParts {
    final length = content.length;
    if (length <= 70) return 1;
    return (length / 67).ceil(); // Arabic SMS parts are 67 chars
  }

  MessageTemplate copyWith({
    String? id,
    String? name,
    String? content,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return MessageTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
