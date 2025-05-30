import 'trip_model.dart';
import 'vehicle_type_model.dart';

class Vehicle {
  final String id;
  final String nameVehicle;
  final String plate;
  final int price;
  final String startTime;
  final String endTime;
  final Trip? trip;
  final VehicleType? vehicleType;

  Vehicle({
    required this.id,
    required this.nameVehicle,
    required this.plate,
    required this.price,
    required this.startTime,
    required this.endTime,
    this.trip,
    this.vehicleType,
  });
}
