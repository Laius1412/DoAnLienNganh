import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type_model.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vehicle>> searchVehiclesByLocation({
    required String startLocation,
    required String destination,
  }) async {
    List<Vehicle> vehicles = [];

    final vehicleSnapshot = await _firestore.collection('vehicle').get();

    for (var doc in vehicleSnapshot.docs) {
      final data = doc.data();
      final tripId = data['tripId'];
      final vehicleTypeId = data['vehicleTypeId'];

      Trip? trip;
      VehicleType? vehicleType;

      // Lấy dữ liệu trip
      if (tripId != null) {
        final tripDoc = await _firestore.collection('trip').doc(tripId).get();
        if (tripDoc.exists) {
          trip = Trip.fromMap(tripDoc.id, tripDoc.data()!);
        }
      }

      // Kiểm tra điều kiện mới
      if (trip != null) {
        final fromMatch = trip.startLocation.toLowerCase() == startLocation.toLowerCase() ||
          trip.intermediateStops.map((e) => e.toLowerCase()).contains(startLocation.toLowerCase());
        final toMatch = trip.destination.toLowerCase() == destination.toLowerCase() ||
          trip.intermediateStops.map((e) => e.toLowerCase()).contains(destination.toLowerCase());
        if (fromMatch && toMatch) {
          // Lấy dữ liệu vehicleType
          if (vehicleTypeId != null) {
            final vtDoc = await _firestore.collection('vehicleType').doc(vehicleTypeId).get();
            if (vtDoc.exists) {
              vehicleType = VehicleType.fromMap(vtDoc.id, vtDoc.data()!);
            }
          }

          vehicles.add(
            Vehicle(
              id: doc.id,
              nameVehicle: data['nameVehicle'],
              plate: data['plate'],
              price: data['price'],
              startTime: data['startTime'],
              endTime: data['endTime'],
              trip: trip,
              vehicleType: vehicleType,
            ),
          );
        }
      }
    }

    return vehicles;
  }
}
