class VehicleType {
  final String id;
  final String nameType;
  final int seatCount;

  VehicleType({
    required this.id,
    required this.nameType,
    required this.seatCount,
  });

  factory VehicleType.fromMap(String id, Map<String, dynamic> data) {
    return VehicleType(
      id: id,
      nameType: data['nameType'],
      seatCount: data['seatCount'],
    );
  }
}
