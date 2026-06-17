class SmsSession {
  final String id;
  final DateTime date;
  final int total;
  final int success;
  final int failed;
  final String templateUsed;
  final String status; // 'completed', 'cancelled', 'in_progress'

  const SmsSession({
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
  }) {
    return SmsSession(
      id: id ?? this.id,
      date: date ?? this.date,
      total: total ?? this.total,
      success: success ?? this.success,
      failed: failed ?? this.failed,
      templateUsed: templateUsed ?? this.templateUsed,
      status: status ?? this.status,
    );
  }
}
