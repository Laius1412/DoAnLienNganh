import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_notification_model.dart';

class BookingNotificationListenerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static StreamSubscription<QuerySnapshot>? _subscription;

  static Function(List<BookingNotification>)? onNotificationsChanged;

  // Bắt đầu lắng nghe
  static void startListening() {
    final user = _auth.currentUser;
    if (user == null) return;

    _subscription?.cancel();

    _subscription = _firestore
        .collection('bookingNotice')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          final notifications = snapshot.docs.map((doc) =>
            BookingNotification.fromMap(doc.id, doc.data() as Map<String, dynamic>)
          ).toList();
          onNotificationsChanged?.call(notifications);
        });
  }

  // Dừng lắng nghe
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  // Khởi tạo listener khi user đăng nhập/đăng xuất
  static void initialize() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        startListening();
      } else {
        stopListening();
        onNotificationsChanged?.call([]);
      }
    });
  }

  // Đánh dấu đã đọc
  static Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('bookingNotice').doc(notificationId).update({'isRead': true});
  }
} 