import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../service/news_service.dart';
import '../views/home_screen/news_detail_screen.dart';

class NewsCarousel extends StatelessWidget {
  const NewsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    const double totalHeight = 280;
    return FutureBuilder<List<NewsModel>>(
      future: NewsService.fetchNews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: \\${snapshot.error}'));
        }
        final newsList = snapshot.data ?? [];
        if (newsList.isEmpty) {
          return Center(child: Text('Chưa có tin tức'));
        }
        return SizedBox(
          height: totalHeight,
          child: PageView.builder(
            itemCount: newsList.length,
            controller: PageController(viewportFraction: 0.92),
            itemBuilder: (context, index) {
              final news = newsList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Ảnh (70%)
                      Expanded(
                        flex: 7,
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            news.img,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              );
                            },
                          ),
                        ),
                      ),
                      // Tiêu đề (30%)
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              news.title,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 