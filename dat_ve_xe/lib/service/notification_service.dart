import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static GlobalKey<NavigatorState>? navigatorKey;

  // Khởi tạo notification service
  static Future<void> initialize() async {
    print('Initializing NotificationService...');

    // Yêu cầu quyền thông báo
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Lấy FCM token hiện tại
    final token = await _messaging.getToken();
    print('Current FCM token: $token');

    // Tạo notification channel cho Android
    await _createNotificationChannel();

    // Lắng nghe thông báo khi app đang foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Lắng nghe khi nhấn vào thông báo (app ở background hoặc terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Lắng nghe thông báo khi app terminated
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);

    // Lắng nghe thay đổi FCM token
    _messaging.onTokenRefresh.listen(_updateFCMToken);

    print('NotificationService initialized successfully');
  }

  // Tạo notification channel cho Android
  static Future<void> _createNotificationChannel() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Xử lý thông báo khi app đang foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    // KHÔNG làm gì cả để không hiện thông báo trong app khi foreground
    // Nếu muốn, có thể log ra debug thôi
    print('Received FCM in foreground, ignore UI: ${message.data}');
  }

  // Xử lý khi nhấn vào thông báo (app ở background)
  static void _handleBackgroundMessageTap(RemoteMessage message) {
    print('Message opened from background: ${message.data}');
    _navigateToDeliveryScreen(message.data);
  }

  // Xử lý thông báo khi app terminated
  static void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      print('Message opened from terminated state: ${message.data}');
      _navigateToDeliveryScreen(message.data);
    }
  }

  // Điều hướng đến màn hình delivery
  static void _navigateToDeliveryScreen(Map<String, dynamic> data) {
    if (data['type'] == 'delivery' && navigatorKey?.currentContext != null) {
      // Điều hướng đến màn hình MyDeliveries
      Navigator.of(navigatorKey!.currentContext!).pushNamed('/myDeliveries');
    }
  }

  // Cập nhật FCM token vào Firestore
  static Future<void> _updateFCMToken(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }

  // Lấy FCM token hiện tại
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Đăng ký topic (nếu cần)
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Hủy đăng ký topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

// Background message handler (phải là top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Không thể điều hướng từ background handler
  // Chỉ có thể log hoặc lưu dữ liệu
}
