import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sender_sms/features/send_sms/data/models/sms_result.dart';

class SmsService {
  static const _channel = MethodChannel('com.school.sender_sms/sms');

  Future<bool> requestPermissions() async => true;

  Future<int> getAndroidApiLevel() async {
    final result = await _channel.invokeMethod<int>('getAndroidApiLevel');
    return result ?? 0;
  }

  Future<bool> isDefaultSmsApp() async {
    final result = await _channel.invokeMethod<bool>('isDefaultSmsApp');
    return result ?? true;
  }

  Future<bool> requestDefaultSmsApp() async {
    final result = await _channel.invokeMethod<bool>('requestDefaultSmsApp');
    return result ?? false;
  }

  Future<SmsResult> sendSms({
    required String to,
    required String message,
    int simSlot = 0,
  }) async {
    try {
      final raw = await _channel
          .invokeMethod<Map<dynamic, dynamic>>(
            'sendSms',
            {'phone': to, 'message': message, 'simSlot': simSlot},
          )
          .timeout(
            const Duration(seconds: 62),
            onTimeout: () => {'success': false, 'error': 'timeout'},
          );

      final success = raw?['success'] == true;
      final error = raw?['error'] as String?;

      if (success) return const SmsResult.success();

      String translatedError = 'فشل إرسال الرسالة';
      if (error != null) {
        if (error == 'timeout') {
          translatedError = 'انتهت مهلة الإرسال (Timeout) - تأكد من تعيين التطبيق كافتراضي أو مراجعة أذونات الخلفية';
        } else if (error == 'generic_failure') {
          translatedError = 'فشل عام (Generic Failure) - قد يكون بسبب نفاد الرصيد أو قيود النظام';
        } else if (error == 'no_service') {
          translatedError = 'لا توجد خدمة (No Service) - تأكد من وجود تغطية للشبكة';
        } else if (error == 'null_pdu') {
          translatedError = 'خطأ في بنية حزمة الرسالة (Null PDU)';
        } else if (error == 'radio_off') {
          translatedError = 'وضع الطيران نشط أو اللاسلكي مغلق (Radio Off)';
        } else if (error == 'limit_exceeded') {
          translatedError = 'تجاوز الحد المسموح به للإرسال في الدقيقة (Limit Exceeded)';
        } else if (error == 'permission_denied') {
          translatedError = 'تم رفض صلاحية إرسال الرسائل (Permission Denied)';
        } else {
          translatedError = error;
        }
      }

      // كشف رصيد منخفض من رسائل Android SmsManager
      final isLowBalance = error != null &&
          (error.contains('low_balance') ||
              error.contains('RESULT_NO_DEFAULT_SMS_APP') ||
              error.contains('3') || // RESULT_ERROR_NO_SERVICE
              error.contains('no_service') ||
              error.contains('generic_failure')
          );

      if (error == 'timeout') {
        return SmsResult.failure(
          errorType: SmsErrorType.timeout,
          errorMessage: translatedError,
        );
      }
      return SmsResult.failure(
        errorType: isLowBalance ? SmsErrorType.lowBalance : SmsErrorType.unknown,
        errorMessage: translatedError,
      );
    } catch (e) {
      return SmsResult.failure(
        errorType: SmsErrorType.unknown,
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getInboxMessages() async {
    try {
      final List<dynamic>? rawList = await _channel.invokeMethod<List<dynamic>>('getInboxMessages');
      if (rawList == null) return [];
      return rawList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> getDevicePhoneNumber() async {
    try {
      final String? number = await _channel.invokeMethod<String>('getDevicePhoneNumber');
      return number ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<void> keepScreenOn(bool keep) async {
    try {
      await _channel.invokeMethod(keep ? 'keepScreenOn' : 'clearKeepScreenOn');
    } catch (_) {}
  }
}
