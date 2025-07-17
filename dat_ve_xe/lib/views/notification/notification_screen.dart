import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/notification_list.dart';
import 'dart:async';

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
      // Lấy deliveryNotice
      final deliverySnapshot = await _firestore
          .collection('deliveryNotice')
          .where('userId', isEqualTo: _currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final List<AppNotification> loadedNotifications = deliverySnapshot.docs.map((doc) {
        final data = doc.data();
        return AppNotification(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['body'] ?? data['content'] ?? '',
          isRead: data['isRead'] ?? false,
          timestamp: data['timestamp'] != null ? DateTime.parse(data['timestamp']) : DateTime.now(),
          source: 'deliveryNotice',
        );
      }).toList();

      // Lấy bookingNotice
      final bookingSnapshot = await _firestore
          .collection('bookingNotice')
          .where('userId', isEqualTo: _currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .get();

      loadedNotifications.addAll(bookingSnapshot.docs.map((doc) {
        final data = doc.data();
        return AppNotification(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          isRead: data['isRead'] ?? false,
          timestamp: data['timestamp'] != null ? DateTime.parse(data['timestamp']) : DateTime.now(),
          source: 'bookingNotice',
        );
      }));

      // Sort tất cả theo timestamp mới nhất
      loadedNotifications.sort((a, b) {
        final at = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });

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
      final collection = notification.source ?? 'deliveryNotice';
      await _firestore.collection(collection).doc(notification.id).update(
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
      if (notification.source == 'bookingNotice') {
        Navigator.pushNamed(context, '/myticket');
      } else {
        Navigator.pushNamed(context, '/myDeliveries');
      }
    }
  }

  Stream<List<AppNotification>> get _notificationsStream {
    if (_currentUser == null) return Stream<List<AppNotification>>.empty();
    final deliveryStream = _firestore
        .collection('deliveryNotice')
        .where('userId', isEqualTo: _currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return AppNotification(
                id: doc.id,
                title: data['title'] ?? '',
                content: data['body'] ?? data['content'] ?? '',
                isRead: data['isRead'] ?? false,
                timestamp: data['timestamp'] != null ? (data['timestamp'] is Timestamp ? (data['timestamp'] as Timestamp).toDate() : DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now()) : DateTime.now(),
                source: 'deliveryNotice',
              );
            }).toList());
    final bookingStream = _firestore
        .collection('bookingNotice')
        .where('userId', isEqualTo: _currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return AppNotification(
                id: doc.id,
                title: data['title'] ?? '',
                content: data['content'] ?? '',
                isRead: data['isRead'] ?? false,
                timestamp: data['timestamp'] != null ? (data['timestamp'] is Timestamp ? (data['timestamp'] as Timestamp).toDate() : DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now()) : DateTime.now(),
                source: 'bookingNotice',
              );
            }).toList());
    return deliveryStream.asyncCombineLatest<List<AppNotification>, List<AppNotification>>(
      bookingStream,
      (delivery, booking) {
        final all = [...delivery, ...booking];
        all.sort((a, b) {
          final at = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bt = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bt.compareTo(at);
        });
        return all;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    debugPrint('DEBUG: Current userId: ${_currentUser?.uid}');
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.notifications),
        actions: [
          StreamBuilder<List<AppNotification>>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
              return NotificationBell(unreadCount: unreadCount);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? [];
          Future.microtask(() {
            debugPrint('DEBUG: Received notifications: ${notifications.length}');
            for (var n in notifications) {
              debugPrint('DEBUG: Notification - id: ${n.id}, title: ${n.title}, isRead: ${n.isRead}, timestamp: ${n.timestamp}, source: ${n.source}');
            }
          });
          if (notifications.isEmpty) {
            return Center(child: Text(loc.noNotifications));
          }
          return NotificationList(
            notifications: notifications,
            onNotificationTap: _onNotificationTap,
          );
        },
      ),
    );
  }
}

// Extension đặt ngoài class
extension AsyncCombineLatestExtension<T> on Stream<T> {
  Stream<R> asyncCombineLatest<S, R>(Stream<S> other, R Function(T, S) combiner) {
    late T latestT;
    late S latestS;
    bool hasT = false;
    bool hasS = false;
    final controller = StreamController<R>();
    final subT = this.listen((t) {
      latestT = t;
      hasT = true;
      if (hasS) controller.add(combiner(latestT, latestS));
    });
    final subS = other.listen((s) {
      latestS = s;
      hasS = true;
      if (hasT) controller.add(combiner(latestT, latestS));
    });
    controller.onCancel = () {
      subT.cancel();
      subS.cancel();
    };
    return controller.stream;
  }
}
