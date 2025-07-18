import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/notification_model.dart';
import 'notification_item.dart';

class NotificationList extends StatefulWidget {
  final List<AppNotification> notifications;
  final Function(AppNotification) onNotificationTap;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
  });

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  int _displayLimit = 10;

  void _loadMore() {
    setState(() {
      _displayLimit += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifications = widget.notifications;
    final limitedNotifications = notifications.take(_displayLimit).toList();
    final now = DateTime.now();
    final today = <AppNotification>[];
    final before = <AppNotification>[];
    for (final n in limitedNotifications) {
      final ts = n.timestamp;
      if (ts == null) {
        before.add(n);
        continue;
      }
      final diff = now.difference(DateTime(ts.year, ts.month, ts.day)).inDays;
      if (diff == 0) {
        today.add(n);
      } else {
        before.add(n);
      }
    }
    final List<Widget> items = [];
    if (today.isNotEmpty) {
      items.add(_SectionHeader(title: AppLocalizations.of(context)!.today));
      items.addAll(today.map((n) => NotificationItem(notification: n, onTap: () => widget.onNotificationTap(n))));
    }
    if (before.isNotEmpty) {
      items.add(_SectionHeader(title: AppLocalizations.of(context)!.earlier));
      items.addAll(before.map((n) => NotificationItem(notification: n, onTap: () => widget.onNotificationTap(n))));
    }
    if (notifications.length > _displayLimit) {
      items.add(_LoadMoreButton(onPressed: _loadMore));
    }
    return Container(
      color: theme.colorScheme.background,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: items,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LoadMoreButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: onPressed,
          icon: const Icon(Icons.expand_more),
          label: Text(AppLocalizations.of(context)!.loadMoreNotifications),
        ),
      ),
    );
  }
} 