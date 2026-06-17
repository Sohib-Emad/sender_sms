import 'dart:async';
import 'package:telephony/telephony.dart';

class SmsService {
  final Telephony _telephony = Telephony.instance;

  Future<bool> requestPermissions() async {
    final granted = await _telephony.requestPhoneAndSmsPermissions;
    return granted ?? false;
  }

  /// Send a single SMS and return true if successful
  Future<bool> sendSms({
    required String to,
    required String message,
    bool isMultipart = false,
  }) async {
    final completer = Completer<bool>();

    try {
      await _telephony.sendSms(
        to: to,
        message: message,
        isMultipart: isMultipart,
        statusListener: (SendStatus status) {
          if (!completer.isCompleted) {
            completer.complete(status == SendStatus.SENT);
          }
        },
      );

      // Wait max 30 seconds for delivery confirmation
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (!completer.isCompleted) completer.complete(true);
          return true;
        },
      );
    } catch (e) {
      if (!completer.isCompleted) completer.complete(false);
      return false;
    }
  }
}
