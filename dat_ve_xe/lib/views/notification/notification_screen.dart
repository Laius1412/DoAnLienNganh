import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/notification_list.dart';

class NotificationScreen extends StatefulWidget {
  final VoidCallback? onNotificationsUpdated;

  const NotificationScreen({super.key, this.onNotificationsUpdated});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<AppNotification> notifications = [];
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _currentUser = currentUser;
      _loadNotifications();
    }
    _auth.authStateChanges().listen((user) {
      if (user != null && user.uid != _currentUser?.uid) {
        _currentUser = user;
        _loadNotifications();
      } else if (user == null) {
        setState(() {
          _currentUser = null;
          notifications = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadNotifications() async {
    if (_currentUser == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      print('Current user: ${_currentUser?.uid}');
      print('Loading notifications...');
      final snapshot =
          await _firestore
              .collection('deliveryNotice')
              .where('userId', isEqualTo: _currentUser!.uid)
              .orderBy('timestamp', descending: true)
              .get();
      print('Found ${snapshot.docs.length} notifications');
      final List<AppNotification> loadedNotifications = [];
      for (var doc in snapshot.docs) {
        print('Notification: ${doc.data()}');
        final data = doc.data();
        loadedNotifications.add(
          AppNotification(
            id: doc.id,
            title: data['title'] ?? '',
            content: data['body'] ?? '',
            isRead: data['isRead'] ?? false,
          ),
        );
      }
      setState(() {
        notifications = loadedNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> markAsRead(AppNotification notification) async {
    try {
      await _firestore.collection('deliveryNotice').doc(notification.id).update(
        {'isRead': true},
      );
      setState(() {
        notification.isRead = true;
      });
    } catch (e) {}
  }

  void _onNotificationTap(AppNotification notification) async {
    await markAsRead(notification);
    if (mounted) {
      Navigator.pushNamed(context, '/myDeliveries');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    int unreadCount = notifications.where((n) => !n.isRead).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.notifications),
        actions: [NotificationBell(unreadCount: unreadCount)],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                ? Center(child: Text(loc.noNotifications))
                : NotificationList(
                  notifications: notifications,
                  onNotificationTap: _onNotificationTap,
                ),
      ),
    );
  }
}
