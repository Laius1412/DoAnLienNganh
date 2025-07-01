import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Widget _section(String title, String content, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 22, color: Colors.deepOrange),
              if (icon != null) const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15.5, height: 1.6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giới thiệu"),
        backgroundColor: const Color(0xFFF36C21), // Màu cam FLASH TRAVEL
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "FLASH TRAVEL – Giải pháp đặt vé xe khách thông minh",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "FLASH TRAVEL là ứng dụng đặt vé xe khách hiện đại, kết nối hàng trăm nhà xe chất lượng khắp cả nước. Với phương châm “Nhanh – An toàn – Tiện lợi”, chúng tôi cam kết mang đến trải nghiệm đặt vé tốt nhất cho người dùng.",
              style: const TextStyle(fontSize: 15.5, height: 1.6),
            ),
            const SizedBox(height: 24),

            _section(
              "Dịch vụ nổi bật",
              "• Xe giường nằm và limousine hiện đại, đầy đủ tiện nghi.\n"
              "• Dịch vụ trung chuyển tận nơi tại nhiều tỉnh thành.\n"
              "• Hỗ trợ đổi trả vé linh hoạt.",
              icon: Icons.directions_bus,
            ),

            _section(
              "Tính năng thông minh",
              "• Đặt vé nhanh trong 3 bước.\n"
              "• Theo dõi hành trình, lưu lịch sử vé.\n"
              "• Thông báo ưu đãi, khuyến mãi mỗi ngày.",
              icon: Icons.smartphone,
            ),

            _section(
              "Lý do chọn FLASH TRAVEL",
              "✓ Giao diện đơn giản, thân thiện.\n"
              "✓ Tích hợp nhiều phương thức thanh toán.\n"
              "✓ Tổng đài hỗ trợ 24/7.\n"
              "✓ Cam kết giá vé minh bạch, rõ ràng.",
              icon: Icons.star,
            ),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/app_icon/icon_App.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'CÔNG TY TNHH VẬN TẢI VÀ DỊCH VỤ DU LỊCH FLASH TRAVEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 18),

            _section(
              "Thông tin công ty",
              "• Công ty TNHH Công nghệ FLASH TRAVEL\n"
              "• Mã số thuế: 0101010101\n"
              "• Trụ sở: Tầng 2, Tòa nhà C50, Quận Hà Đông, TP.Hà Nội\n"
              "• Email: support@flashtravel.vn\n"
              "• Hotline đặt vé: 1900 1234 (1.000đ/phút)",
              icon: Icons.business,
            ),

            _section(
              "Theo dõi chúng tôi",
              "• Website: www.flashtravel.vn\n"
              "• Facebook: fb.com/flashtravel.vn\n"
              "• Zalo OA: FLASH TRAVEL\n"
              "• TikTok: @flashtravel.vn",
              icon: Icons.public,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
