import 'package:flutter/material.dart';

class PriceCarousel extends StatelessWidget {
  const PriceCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu sử dụng ảnh asset và loại xe
    final List<Map<String, String>> priceList = [
      {
        'route': 'Hà Nội - Nghệ An',
        'price': '300.000đ',
        'img': 'assets/picture_price/nghean.png',
        'type': 'Xe giường nằm 34,38',
      },
      {
        'route': 'Hà Nội - Nghệ An',
        'price': '450.000đ',
        'img': 'assets/picture_price/hanoi1.png',
        'type': 'Xe limousine',
      },
      {
        'route': 'Hà Nội - Thanh Hóa',
        'price': '200.000đ',
        'img': 'assets/app_icon/hinh_anh_gioi_thieu_1.png',
        'type': 'Xe ghế ngồi',
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black87;
    final iconColor = isDark ? Colors.orange[200] : Colors.orange;
    final imageErrorColor = isDark ? Colors.grey[800] : Colors.grey[300];
    final iconErrorColor = isDark ? Colors.grey[400] : Colors.grey;

    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: priceList.length,
        controller: PageController(viewportFraction: 0.92),
        itemBuilder: (context, index) {
          final item = priceList[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                  child: Image.asset(
                    item['img']!,
                    width: 110,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 110,
                        height: 180,
                        color: imageErrorColor,
                        child: Icon(Icons.broken_image, color: iconErrorColor, size: 40),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.swap_vert, color: iconColor),
                            SizedBox(width: 6),
                            Text(
                              item['route']!,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.directions_transit, color: iconColor),
                            SizedBox(width: 6),
                            Text(
                              item['type'] ?? '',
                              style: TextStyle(fontSize: 15, color: subTextColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.confirmation_number, color: iconColor),
                            SizedBox(width: 6),
                            Text(
                            item['price']!,
                            style: TextStyle(fontSize: 16, color: iconColor, fontWeight: FontWeight.w600),
                          ),
                          ],
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 