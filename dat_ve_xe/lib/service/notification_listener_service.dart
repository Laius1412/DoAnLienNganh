import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationListenerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static StreamSubscription<QuerySnapshot>? _subscription;

  static Function(int)? onUnreadCountChanged;

  // Bắt đầu lắng nghe notifications
  static void startListening() {
    final user = _auth.currentUser;
    if (user == null) return;

    _subscription?.cancel();

    _subscription = _firestore
        .collection('deliveryNotice')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          final unreadCount = snapshot.docs.length;
          onUnreadCountChanged?.call(unreadCount);
        });
  }

  // Dừng lắng nghe
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  // Khởi tạo listener khi user đăng nhập
  static void initialize() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        startListening();
      } else {
        stopListening();
        onUnreadCountChanged?.call(0);
      }
    });
  }
}
