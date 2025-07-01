import 'package:flutter/material.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({Key? key}) : super(key: key);

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
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
        title: const Text('Chính sách & Điều khoản dịch vụ'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              '1. Chính sách đặt vé',
              '• Khách hàng có thể đặt vé trực tuyến qua ứng dụng FLASH TRAVEL hoặc website.\n'
              '• Vé chỉ có giá trị khi đã thanh toán thành công.\n'
              '• Thông tin hành khách phải chính xác để đảm bảo quyền lợi khi lên xe.',
            ),
            _section(
              '2. Chính sách thanh toán',
              '• Hỗ trợ nhiều hình thức thanh toán: Momo, thẻ ATM, Visa/MasterCard, chuyển khoản.\n'
              '• FLASH TRAVEL cam kết bảo mật thông tin thanh toán của khách hàng.',
            ),
            _section(
              '3. Chính sách đổi/trả vé',
              '• Khách hàng được phép đổi/trả vé trước giờ khởi hành theo quy định của từng nhà xe.\n'
              '• Phí đổi/trả vé (nếu có) sẽ được thông báo trước khi xác nhận thao tác.\n'
              '• Tiền hoàn vé sẽ được chuyển về tài khoản trong vòng 3-7 ngày làm việc.',
            ),
            _section(
              '4. Quy định sử dụng dịch vụ',
              '• Không sử dụng dịch vụ vào mục đích vi phạm pháp luật.\n'
              '• Không được mua bán, chuyển nhượng vé trái quy định.\n'
              '• FLASH TRAVEL có quyền từ chối phục vụ nếu phát hiện hành vi gian lận.',
            ),
            _section(
              '5. Chính sách bảo mật',
              '• FLASH TRAVEL cam kết bảo mật tuyệt đối thông tin cá nhân của khách hàng.\n'
              '• Không chia sẻ thông tin cho bên thứ ba nếu không có sự đồng ý của khách hàng, trừ trường hợp theo yêu cầu pháp luật.',
            ),
            _section(
              '6. Hỗ trợ khách hàng',
              '• Hotline: 1900 1234 (1.000đ/phút)\n'
              '• Email: support@flashtravel.vn\n'
              '• Hỗ trợ 24/7 qua ứng dụng, website và các kênh mạng xã hội.',
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              'Việc sử dụng dịch vụ FLASH TRAVEL đồng nghĩa với việc bạn đã đọc, hiểu và đồng ý với các chính sách, điều khoản trên.',
              style: const TextStyle(fontSize: 14.5, color: Colors.black54, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 