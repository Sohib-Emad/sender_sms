import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';
import 'package:sender_sms/features/notifications/data/models/app_notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final HiveDatasource _hiveDatasource;
  StreamSubscription? _subscription;

  NotificationsCubit(this._hiveDatasource) : super(NotificationsInitial()) {
    _subscription = _hiveDatasource.notifications.watch().listen((_) {
      _loadNotifications();
    });
    _loadNotifications();
  }

  void _loadNotifications() {
    final list = _hiveDatasource.getAllNotifications();
    final unread = list.where((n) => !n.isRead).length;
    emit(NotificationsLoaded(notifications: list, unreadCount: unread));
  }

  Future<void> markAllAsRead() async {
    final list = _hiveDatasource.getAllNotifications();
    for (final n in list) {
      if (!n.isRead) {
        n.isRead = true;
        await n.save();
      }
    }
    try {
      await AppBadgePlus.updateBadge(0);
    } catch (_) {}
    _loadNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await _hiveDatasource.deleteNotification(id);
    _updateBadge();
    _loadNotifications();
  }

  Future<void> clearAll() async {
    await _hiveDatasource.clearNotifications();
    try {
      await AppBadgePlus.updateBadge(0);
    } catch (_) {}
    _loadNotifications();
  }

  Future<void> _updateBadge() async {
    try {
      final unread = _hiveDatasource.notifications.values.where((n) => !n.isRead).length;
      await AppBadgePlus.updateBadge(unread);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
