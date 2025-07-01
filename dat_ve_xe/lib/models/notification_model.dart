class AppNotification {
  final String id;
  final String title;
  final String content;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    this.isRead = false,
  });
}
