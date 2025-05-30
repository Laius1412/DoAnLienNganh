class SeatPosition {
  final String id;
  final String numberSeat;
  final bool isBooked;
  final String date; // Store date as YYYY-MM-DD string format

  SeatPosition({
    required this.id,
    required this.numberSeat,
    this.isBooked = false,
    required this.date,
  });

  factory SeatPosition.fromMap(String id, Map<String, dynamic> data) {
    return SeatPosition(
      id: id,
      numberSeat: data['numberSeat'] ?? '',
      isBooked: data['isBooked'] ?? false,
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numberSeat': numberSeat,
      'isBooked': isBooked,
      'date': date,
    };
  }
} 