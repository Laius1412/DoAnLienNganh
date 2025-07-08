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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
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
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
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
                            Icon(Icons.swap_vert),
                            SizedBox(width: 6),
                            Text(
                              item['route']!,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.directions_transit),
                            SizedBox(width: 6),
                            Text(
                              item['type'] ?? '',
                              style: TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.confirmation_number),
                            SizedBox(width: 6),
                            Text(
                            item['price']!,
                            style: TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.w600),
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