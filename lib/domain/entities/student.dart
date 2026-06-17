class Student {
  final String id;
  final String name;
  final String phone;
  final String degree;
  final DateTime createdAt;

  const Student({
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
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      degree: degree ?? this.degree,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Student(id: $id, name: $name, phone: $phone)';
}
