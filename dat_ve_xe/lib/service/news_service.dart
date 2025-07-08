import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

class NewsService {
  static Future<List<NewsModel>> fetchNews() async {
    final snapshot = await FirebaseFirestore.instance.collection('news').orderBy('createAt', descending: true).get();
    return snapshot.docs.map((doc) => NewsModel.fromMap(doc.id, doc.data())).toList();
  }
} 