import 'package:equatable/equatable.dart';

enum SmsErrorType { unknown, lowBalance, permissionDenied, timeout }

class SmsResult extends Equatable {
  final bool success;
  final SmsErrorType? errorType;
  final String? errorMessage;

  const SmsResult.success()
      : success = true,
        errorType = null,
        errorMessage = null;

  const SmsResult.failure({required this.errorType, this.errorMessage})
      : success = false;

  bool get isLowBalance => errorType == SmsErrorType.lowBalance;

  @override
  List<Object?> get props => [success, errorType, errorMessage];
}
