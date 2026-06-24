class SendProgress {
  final int total;
  final int sent;
  final int failed;
  final String currentStudentName;
  final String currentPhone;
  final bool isPaused;
  final bool isCompleted;
  final bool isCancelled;
  final bool isLowBalance;
  final bool isError;
  final String? errorMessage;
  final bool isRunning;
  final String sessionId;
  final List<LogEntry> recentLogs;

  const SendProgress({
    this.total = 0,
    this.sent = 0,
    this.failed = 0,
    this.currentStudentName = '',
    this.currentPhone = '',
    this.isPaused = false,
    this.isCompleted = false,
    this.isCancelled = false,
    this.isLowBalance = false,
    this.isError = false,
    this.errorMessage,
    this.isRunning = false,
    this.sessionId = '',
    this.recentLogs = const [],
  });

  int get remaining => total - sent - failed;
  double get progressPercent => total == 0 ? 0 : ((sent + failed) / total);
  int get processedCount => sent + failed;

  SendProgress copyWith({
    int? total,
    int? sent,
    int? failed,
    String? currentStudentName,
    String? currentPhone,
    bool? isPaused,
    bool? isCompleted,
    bool? isCancelled,
    bool? isLowBalance,
    bool? isError,
    String? errorMessage,
    bool? isRunning,
    String? sessionId,
    List<LogEntry>? recentLogs,
  }) {
    return SendProgress(
      total: total ?? this.total,
      sent: sent ?? this.sent,
      failed: failed ?? this.failed,
      currentStudentName: currentStudentName ?? this.currentStudentName,
      currentPhone: currentPhone ?? this.currentPhone,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
      isLowBalance: isLowBalance ?? this.isLowBalance,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      isRunning: isRunning ?? this.isRunning,
      sessionId: sessionId ?? this.sessionId,
      recentLogs: recentLogs ?? this.recentLogs,
    );
  }
}

class LogEntry {
  final String studentName;
  final String phone;
  final bool success;
  final String? error;
  final DateTime time;

  const LogEntry({
    required this.studentName,
    required this.phone,
    required this.success,
    this.error,
    required this.time,
  });
}
