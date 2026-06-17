class SmsLog {
  final String id;
  final String sessionId;
  final String studentName;
  final String phone;
  final String message;
  final String status; // 'sent', 'failed', 'pending'
  final String? errorMessage;
  final DateTime sentAt;

  const SmsLog({
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
  }) {
    return SmsLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentName: studentName ?? this.studentName,
      phone: phone ?? this.phone,
      message: message ?? this.message,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
