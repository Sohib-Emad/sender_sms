import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/notifications/data/models/app_notification.dart';
import 'package:sender_sms/features/notifications/logic/notifications_cubit.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsCubit>().markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                  onPressed: () => _confirmClearAll(context),
                  tooltip: 'مسح الكل',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsLoaded) {
            final list = state.notifications;
            if (list.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = list[index];
                return _buildNotificationCard(context, notification, index);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          const Text(
            'لا توجد إشعارات حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          const Text(
            'ستظهر هنا الإشعارات والرسائل التي تصلك',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    int index,
  ) {
    final formattedTime = intl.DateFormat('yyyy-MM-dd hh:mm a').format(notification.timestamp);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<NotificationsCubit>().deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم مسح الإشعار بنجاح', textDirection: TextDirection.rtl),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: notification.isRead
                  ? null
                  : const Border(
                      right: BorderSide(
                        color: AppColors.primary,
                        width: 5,
                      ),
                    ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
     .slideX(begin: 0.1, duration: 250.ms, delay: (index * 40).ms)
     .fadeIn(delay: (index * 40).ms);
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('مسح جميع الإشعارات؟', textDirection: TextDirection.rtl),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<NotificationsCubit>().clearAll();
              Navigator.pop(dialogCtx);
            },
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }
}
