import 'package:cloud_firestore/cloud_firestore.dart';

// Model cho dữ liệu khu vực (regions)
class Region {
  final String id;
  final String regionName;

  Region({required this.id, required this.regionName});

  factory Region.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Region(
      id: doc.id,
      regionName: data['regionName'] ?? 'Unknown Region',
    );
  }
}

// Model cho dữ liệu bảng giá (priceDelivery)
class PriceDelivery {
  final String id;
  final String fromRegionId;
  final String toRegionId;
  final List<Map<String, dynamic>> weightRanges;

  PriceDelivery({
    required this.id,
    required this.fromRegionId,
    required this.toRegionId,
    required this.weightRanges,
  });

  factory PriceDelivery.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PriceDelivery(
      id: doc.id,
      fromRegionId: data['fromRegionId'] ?? '',
      toRegionId: data['toRegionId'] ?? '',
      weightRanges: List<Map<String, dynamic>>.from(data['weightRanges'] ?? []),
    );
  }
}

// Model cho đơn hàng chuyển phát (deliveryOrders)
class DeliveryOrder {
  final String id;
  final String cccd;
  final String cod;
  final DateTime createdAt;
  final String details;
  final String fromOfficeId;
  final String fromRegionId;
  final String nameFrom;
  final String nameTo;
  final String orderValue;
  final String phoneFrom;
  final String phoneTo;
  final double mass;
  final double price;
  final String status;
  final String toOfficeId;
  final String toRegionId;
  final String type;
  final String typePayment;
  final String userId;
  final DateTime? updatedAt;

  DeliveryOrder({
    required this.id,
    required this.cccd,
    required this.cod,
    required this.createdAt,
    required this.details,
    required this.fromOfficeId,
    required this.fromRegionId,
    required this.nameFrom,
    required this.nameTo,
    required this.orderValue,
    required this.phoneFrom,
    required this.phoneTo,
    required this.mass,
    required this.price,
    required this.status,
    required this.toOfficeId,
    required this.toRegionId,
    required this.type,
    required this.typePayment,
    required this.userId,
    this.updatedAt,
  });

  factory DeliveryOrder.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DeliveryOrder(
      id: data['id'] ?? doc.id,
      cccd: data['cccd'] ?? '',
      cod: data['cod'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      details: data['details'] ?? '',
      fromOfficeId: data['fromOfficeId'] ?? '',
      fromRegionId: data['fromRegionId'] ?? '',
      nameFrom: data['nameFrom'] ?? '',
      nameTo: data['nameTo'] ?? '',
      orderValue: data['orderValue']?.toString() ?? '',
      phoneFrom: data['phoneFrom'] ?? '',
      phoneTo: data['phoneTo'] ?? '',
      mass: _parseToDouble(data['mass']),
      price: _parseToDouble(data['price']),
      status: data['status'] ?? '',
      toOfficeId: data['toOfficeId'] ?? '',
      toRegionId: data['toRegionId'] ?? '',
      type: data['type'] ?? '',
      typePayment: data['typePayment'] ?? '',
      userId: data['userId'] ?? '',
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  String getStatusText(String language) {
    switch (status) {
      case 'pending':
        return language == 'vi' ? 'Chờ xác nhận' : 'Pending';
      case 'confirmed':
        return language == 'vi' ? 'Đã được xác nhận' : 'Confirmed';
      case 'accepted':
        return language == 'vi' ? 'Đã tiếp nhận' : 'Accepted';
      case 'delivering':
        return language == 'vi' ? 'Đang vận chuyển' : 'Delivering';
      case 'delivered':
        return language == 'vi' ? 'Đã tới nơi' : 'Delivered';
      case 'returning':
        return language == 'vi' ? 'Đang hoàn trả' : 'Returning';
      case 'returned':
        return language == 'vi' ? 'Đã hoàn trả' : 'Returned';
      case 'received':
        return language == 'vi' ? 'Người nhận đã nhận hàng' : 'Received';
      case 'refused':
        return language == 'vi' ? 'Từ chối nhận hàng' : 'Refused';
      default:
        return language == 'vi' ? 'Chờ xác nhận' : 'Pending';
    }
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
