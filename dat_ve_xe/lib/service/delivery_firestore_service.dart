import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ước tính giá cước dựa trên khu vực gửi/nhận, khối lượng, và loại hàng
  static Future<int> estimatePrice(
    String fromRegionId,
    String toRegionId,
    double mass,
    bool isHighValue,
  ) async {
    final snapshot = await _firestore.collection('priceDelivery').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final fromId = data['fromRegionId'];
      final toId = data['toRegionId'];

      final isMatch =
          (fromId == fromRegionId && toId == toRegionId) ||
          (fromId == toRegionId && toId == fromRegionId);
      if (!isMatch) continue;

      final ranges = List<Map<String, dynamic>>.from(data['weightRanges']);
      for (final range in ranges) {
        final min = (range['min'] as num).toDouble();
        final max = (range['max'] as num).toDouble();
        if (mass >= min && mass <= max) {
          int basePrice = (range['price'] as num).toInt();
          if (isHighValue) basePrice += 100000;
          return basePrice;
        }
      }
    }

    // Không tìm thấy bảng giá phù hợp
    return 0;
  }

  /// Gửi đơn hàng mới lên Firestore
  static Future<void> createDelivery(Map<String, dynamic> orderData) async {
    final id = orderData['id'];
    await _firestore.collection('deliveryOrders').doc(id).set(orderData);
  }
}
