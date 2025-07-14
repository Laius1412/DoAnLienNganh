class AppNotification {
  final String id;
  final String title;
  final String content;
  final DateTime? timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    this.timestamp,
    this.isRead = false,
  });
}
