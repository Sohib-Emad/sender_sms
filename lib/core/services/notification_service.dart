import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';
import 'package:sender_sms/features/notifications/data/models/app_notification.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppNotificationAdapter());
    }
    final box = await Hive.openBox<AppNotification>(HiveDatasource.notificationsBox);

    final title = message.notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final id = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Check if already exists to avoid duplicates
    if (!box.containsKey(id)) {
      final notification = AppNotification(
        id: id,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await box.put(id, notification);
    }

    final unreadCount = box.values.where((n) => !n.isRead).length;
    await AppBadgePlus.updateBadge(unreadCount);
  } catch (e) {
    print('Error in background message handler: $e');
  }
}

class NotificationService {
  final HiveDatasource _hiveDatasource;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  NotificationService(this._hiveDatasource);

  Future<void> init() async {
    // Request notification permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the FCM token for console debugging/testing
    try {
      final token = await _fcm.getToken();
      print("FCM Token: $token");
    } catch (e) {
      print("Error getting FCM Token: $e");
    }

    // Configure foreground notifications behavior on iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications for foreground alerts
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );

    // Set up Android Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel_id', // id
      'Default Channel', // title
      description: 'Notifications channel', // description
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Update app badge count on startup from stored unread notifications
    _updateAppBadge();

    // 1. Listen to messages in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _handleIncomingMessage(message, showLocal: true);
    });

    // 2. Handle when app is in background but opened from notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handleIncomingMessage(message, showLocal: false);
    });

    // 3. Check if app was opened from a completely terminated state via notification tap
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      await _handleIncomingMessage(initialMessage, showLocal: false);
    }
  }

  Future<void> _handleIncomingMessage(RemoteMessage message, {required bool showLocal}) async {
    final title = message.notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final id = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Check if notification is already stored
    final box = _hiveDatasource.notifications;
    if (!box.containsKey(id)) {
      final notification = AppNotification(
        id: id,
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
      );
      await _hiveDatasource.saveNotification(notification);
    }

    await _updateAppBadge();

    if (showLocal) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_channel_id',
        'Default Channel',
        channelDescription: 'Notifications channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        id: id.hashCode,
        title: title,
        body: body,
        notificationDetails: details,
      );
    }
  }

  Future<void> _updateAppBadge() async {
    try {
      final unreadCount = _hiveDatasource.notifications.values.where((n) => !n.isRead).length;
      await AppBadgePlus.updateBadge(unreadCount);
    } catch (e) {
      print("Error updating app badge: $e");
    }
  }
}
