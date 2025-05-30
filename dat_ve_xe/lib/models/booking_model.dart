import 'vehicle_type_model.dart';
import 'seat_position_model.dart';
import 'vehicle_model.dart';
import 'trip_model.dart';

class BookingSeat {
  final SeatPosition? seatPosition;
  final Vehicle? vehicle;

  BookingSeat({
    this.seatPosition,
    this.vehicle,
  });

  Map<String, dynamic> toMap() {
    return {
      if (seatPosition != null) 'seatPosition': seatPosition!.toMap(),
      if (vehicle != null) 'vehicle': _vehicleToMap(vehicle!),
    };
  }

  Map<String, dynamic> _vehicleToMap(Vehicle vehicle) {
    return {
      'id': vehicle.id,
      'nameVehicle': vehicle.nameVehicle,
      'plate': vehicle.plate,
      'price': vehicle.price,
      'startTime': vehicle.startTime,
      'endTime': vehicle.endTime,
      if (vehicle.trip != null) 'trip': {
        'id': vehicle.trip!.id,
        'destination': vehicle.trip!.destination,
        'nameTrip': vehicle.trip!.nameTrip,
        'startLocation': vehicle.trip!.startLocation,
        'tripCode': vehicle.trip!.tripCode,
        'vRouter': vehicle.trip!.vRouter,
      },
      if (vehicle.vehicleType != null) 'vehicleType': {
        'id': vehicle.vehicleType!.id,
        'nameType': vehicle.vehicleType!.nameType,
        'seatCount': vehicle.vehicleType!.seatCount,
      },
    };
  }

  factory BookingSeat.fromMap(Map<String, dynamic> map) {
    return BookingSeat(
      seatPosition: map['seatPosition'] != null 
          ? SeatPosition.fromMap(map['seatPosition']['id'], map['seatPosition']) 
          : null,
      vehicle: map['vehicle'] != null 
          ? Vehicle(
              id: map['vehicle']['id'],
              nameVehicle: map['vehicle']['nameVehicle'],
              plate: map['vehicle']['plate'],
              price: map['vehicle']['price'],
              startTime: map['vehicle']['startTime'],
              endTime: map['vehicle']['endTime'],
              trip: map['vehicle']['trip'] != null
                  ? Trip.fromMap(
                      map['vehicle']['trip']['id'],
                      map['vehicle']['trip'],
                    )
                  : null,
              vehicleType: map['vehicle']['vehicleType'] != null
                  ? VehicleType.fromMap(
                      map['vehicle']['vehicleType']['id'],
                      map['vehicle']['vehicleType'],
                    )
                  : null,
            )
          : null,
    );
  }
}

class Booking {
  final String id;
  final String userId;
  final DateTime createDate;
  final String startLocationBooking;
  final String endLocationBooking;
  final String statusBooking;
  final int totalPrice;
  final List<BookingSeat> seats;

  Booking({
    required this.id,
    required this.userId,
    required this.createDate,
    required this.startLocationBooking,
    required this.endLocationBooking,
    required this.statusBooking,
    required this.totalPrice,
    required this.seats,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'createDate': createDate.toIso8601String(),
      'startLocationBooking': startLocationBooking,
      'endLocationBooking': endLocationBooking,
      'statusBooking': statusBooking,
      'totalPrice': totalPrice,
      'seats': seats.map((e) => e.toMap()).toList(),
    };
  }

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'],
      createDate: DateTime.parse(map['createDate']),
      startLocationBooking: map['startLocationBooking'],
      endLocationBooking: map['endLocationBooking'],
      statusBooking: map['statusBooking'],
      totalPrice: map['totalPrice'],
      seats: (map['seats'] as List<dynamic>)
          .map((e) => BookingSeat.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}