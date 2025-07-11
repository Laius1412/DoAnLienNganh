import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Color.fromARGB(255, 253, 109, 37);
    final Color unreadColor = const Color(0xFFF8F5FB).withOpacity(0.5); 
    final Color readColor = const Color(0xFFF8F5FB);
    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          color: notification.isRead ? readColor : unreadColor,
          child: ListTile(
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(notification.content),
            onTap: onTap,
          ),
        ),
        if (!notification.isRead)
          Positioned(
            right: 10,
            top: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
} 