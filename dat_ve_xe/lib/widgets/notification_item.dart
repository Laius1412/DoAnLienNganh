import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final theme = Theme.of(context);
    final Color borderColor = theme.colorScheme.primary;
    final Color unreadColor = theme.colorScheme.secondaryContainer;
    final Color readColor = theme.colorScheme.surface;
    final Color dotColor = theme.colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            Card(
              elevation: notification.isRead ? 1 : 4,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: borderColor.withOpacity(notification.isRead ? 0.2 : 0.7), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              color: notification.isRead ? readColor : unreadColor,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  notification.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: notification.isRead ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    if (notification.timestamp != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _formatTimestamp(notification.timestamp!, context),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: notification.isRead ? null : Icon(Icons.fiber_manual_record, color: dotColor, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(time);
    final loc = AppLocalizations.of(context);
    if (diff.inMinutes < 1) {
      return loc?.justNow ?? 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${loc?.minutesAgo ?? 'phút trước'}';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ${loc?.hoursAgo ?? 'giờ trước'}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ${loc?.daysAgo ?? 'ngày trước'}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} '
        '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
    }
  }
}
