class AppNotification {
  final String id;
  final String title;
  final String content;
  final DateTime? timestamp;
  bool isRead;
  final String? source;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    this.timestamp,
    this.isRead = false,
    this.source,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> data, {String? source}) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      content: data['body'] ?? data['content'] ?? '',
      timestamp: data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) : null,
      isRead: data['isRead'] ?? false,
      source: source,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp?.toIso8601String(),
      'isRead': isRead,
      'source': source,
    };
  }
}
