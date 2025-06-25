class SeatPosition {
  final String id;
  final String numberSeat;
  final bool isBooked;
  final String date; // Store date as YYYY-MM-DD string format
  final String? holdBy; // userId đang giữ chỗ
  final String? holdUntil; // thời gian giữ chỗ tạm thời (ISO8601)

  SeatPosition({
    required this.id,
    required this.numberSeat,
    this.isBooked = false,
    required this.date,
    this.holdBy,
    this.holdUntil,
  });

  factory SeatPosition.fromMap(String id, Map<String, dynamic> data) {
    return SeatPosition(
      id: id,
      numberSeat: data['numberSeat'] ?? '',
      isBooked: data['isBooked'] ?? false,
      date: data['date'] ?? '',
      holdBy: data['holdBy'],
      holdUntil: data['holdUntil'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numberSeat': numberSeat,
      'isBooked': isBooked,
      'date': date,
      if (holdBy != null) 'holdBy': holdBy,
      if (holdUntil != null) 'holdUntil': holdUntil,
    };
  }
} 