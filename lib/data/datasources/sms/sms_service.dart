import 'dart:async';
import 'package:flutter/services.dart';

class SmsService {
  static const _channel = MethodChannel('com.school.sender_sms/sms');

  Future<bool> requestPermissions() async {
    return true;
  }

  Future<bool> isDefaultSmsApp() async {
    final result = await _channel.invokeMethod<bool>('isDefaultSmsApp');
    return result ?? true;
  }

  Future<bool> requestDefaultSmsApp() async {
    final result = await _channel.invokeMethod<bool>('requestDefaultSmsApp');
    return result ?? false;
  }

  Future<bool> sendSms({
    required String to,
    required String message,
    bool isMultipart = false,
    int simSlot = 0,
  }) async {
    final completer = Completer<bool>();

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'sendSms',
        {
          'phone': to,
          'message': message,
          'simSlot': simSlot,
        },
      );

      final success = result?['success'] == true;
      if (!completer.isCompleted) {
        completer.complete(success);
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future.timeout(
      const Duration(seconds: 32),
      onTimeout: () {
        if (!completer.isCompleted) completer.complete(true);
        return true;
      },
    );
  }
}
