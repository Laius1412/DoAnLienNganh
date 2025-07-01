import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/notification_list.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> notifications = [
    AppNotification(id: '1', title: 'Chào mừng', content: 'Chào mừng bạn đến với ứng dụng!', isRead: false),
    AppNotification(id: '2', title: 'Khuyến mãi', content: 'Nhận ngay ưu đãi 50%!', isRead: false),
    AppNotification(id: '3', title: 'Cập nhật', content: 'Ứng dụng đã được cập nhật.', isRead: true),
  ];

  void markAsRead(AppNotification notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          NotificationBell(unreadCount: unreadCount),
        ],
      ),
      body: NotificationList(
        notifications: notifications,
        onNotificationTap: markAsRead,
      ),
    );
  }
}
