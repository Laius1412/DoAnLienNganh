import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String id;
  final String img;
  final String title;
  final String content;
  final DateTime createdAt;

  NewsModel({
    required this.id,
    required this.img,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory NewsModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime created;
    if (data['createAt'] is Timestamp) {
      created = (data['createAt'] as Timestamp).toDate();
    } else if (data['createAt'] is String) {
      created = DateTime.tryParse(data['createAt']) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }
    return NewsModel(
      id: id,
      img: data['Img'] ?? '',
      title: data['titles'] ?? '',
      content: data['contents'] ?? '',
      createdAt: created,
    );
  }
} 