import 'package:cloud_firestore/cloud_firestore.dart';

class BookingNotification {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String bookingId;

  BookingNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.type,
    required this.bookingId,
  });

  factory BookingNotification.fromMap(String id, Map<String, dynamic> data) {
    DateTime ts;
    if (data['timestamp'] is String) {
      ts = DateTime.parse(data['timestamp']);
    } else if (data['timestamp'] is Timestamp) {
      ts = (data['timestamp'] as Timestamp).toDate();
    } else {
      ts = DateTime.now();
    }
    return BookingNotification(
      id: id,
      userId: data['userId'],
      title: data['title'],
      content: data['content'],
      timestamp: ts,
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? '',
      bookingId: data['bookingId'] ?? '',
    );
  }
} 