import 'package:flutter/material.dart';
import 'package:dat_ve_xe/models/vehicle_model.dart';
import 'package:dat_ve_xe/server/vehicle_service.dart';
import 'package:intl/intl.dart';
import 'booking_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String startLocation;
  final String destination;
  final DateTime selectedDate;

  const SearchResultScreen({
    Key? key,
    required this.startLocation,
    required this.destination,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final VehicleService _vehicleService = VehicleService();
  late Future<List<Vehicle>> _vehicleFuture;

  @override
  void initState() {
    super.initState();
    _vehicleFuture = _vehicleService.searchVehiclesByLocation(
      startLocation: widget.startLocation,
      destination: widget.destination,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả (${dateFormat.format(widget.selectedDate)})'),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return Center(child: Text('Không tìm thấy xe phù hợp.'));
          }

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(
                        vehicle: vehicle,
                        startLocation: widget.startLocation,
                        destination: widget.destination,
                        selectedDate: widget.selectedDate,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${vehicle.vehicleType?.nameType}',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              '${vehicle.vehicleType?.seatCount} chỗ',
                              style: TextStyle(color: Colors.lightGreenAccent),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              vehicle.startTime,
                              style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '-',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text(
                              vehicle.endTime,
                              style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${vehicle.trip?.startLocation}', style: TextStyle(color: Colors.white)),
                            Text('${vehicle.trip?.destination}', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Divider(color: Colors.grey[300], thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${vehicle.trip?.vRouter}', style: TextStyle(color: Colors.white)),
                            Text(
                              '${NumberFormat("#,###", "vi_VN").format(vehicle.price)}đ',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
