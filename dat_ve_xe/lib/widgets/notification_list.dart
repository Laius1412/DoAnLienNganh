import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'notification_item.dart';

class NotificationList extends StatelessWidget {
  final List<AppNotification> notifications;
  final Function(AppNotification) onNotificationTap;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationItem(
          notification: notification,
          onTap: () => onNotificationTap(notification),
        );
      },
    );
  }
} 