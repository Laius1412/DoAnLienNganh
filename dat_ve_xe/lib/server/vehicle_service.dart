import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type_model.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vehicle>> searchVehiclesByLocation({
    required String startLocation,
    required String destination,
    bool searchByStopsStart = false,
    bool searchByStopsEnd = false,
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
        // Flatten all stop locations (city + locations) into a single list
        final allLocations = <String>[];
        final allCities = <String>[];
        for (final stop in trip.stops) {
          allCities.add(stop.city);
          for (final loc in stop.locations) {
            allLocations.add(loc);
          }
        }
        final allLocationsLower = allLocations.map((e) => e.toLowerCase()).toList();
        final allCitiesLower = allCities.map((e) => e.toLowerCase()).toList();
        int fromIndex = -1;
        int toIndex = -1;
        if (searchByStopsStart) {
          // Ưu tiên tìm theo location, nếu không có thì tìm theo city
          fromIndex = allLocationsLower.indexOf(startLocation.toLowerCase());
          if (fromIndex == -1) {
            fromIndex = allCitiesLower.indexOf(startLocation.toLowerCase());
          }
        } else {
          fromIndex = trip.startLocation.toLowerCase() == startLocation.toLowerCase()
              ? 0
              : -1;
        }
        if (searchByStopsEnd) {
          toIndex = allLocationsLower.indexOf(destination.toLowerCase());
          if (toIndex == -1) {
            toIndex = allCitiesLower.indexOf(destination.toLowerCase());
          }
        } else {
          toIndex = trip.destination.toLowerCase() == destination.toLowerCase()
              ? allLocationsLower.length - 1
              : -1;
        }
        final fromMatch = fromIndex != -1;
        final toMatch = toIndex != -1;
        // startLocation phải đứng trước destination trong danh sách stops hoặc cities
        if (fromMatch && toMatch && fromIndex < toIndex) {
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
