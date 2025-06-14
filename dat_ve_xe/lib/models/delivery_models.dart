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
