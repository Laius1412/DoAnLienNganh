import 'package:flutter/material.dart';
import 'package:dat_ve_xe/models/vehicle_model.dart';
import 'package:dat_ve_xe/server/vehicle_service.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
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
  final BookingService _bookingService = BookingService();
  late Future<List<Vehicle>> _vehicleFuture;
  Map<String, int> _availableSeats = {};

  @override
  void initState() {
    super.initState();
    _vehicleFuture = _vehicleService.searchVehiclesByLocation(
      startLocation: widget.startLocation,
      destination: widget.destination,
    ).then((vehicles) async {
      // Lấy số ghế còn trống cho mỗi xe
      for (var vehicle in vehicles) {
        final bookedSeats = await _bookingService.getBookedSeatsForVehicle(
          vehicle.id,
          widget.selectedDate,
        );
        final totalSeats = vehicle.vehicleType?.seatCount ?? 0;
        final availableSeats = totalSeats - bookedSeats.length;
        _availableSeats[vehicle.id] = availableSeats;
      }
      return vehicles;
    });
  }

  // Tính thời gian di chuyển
  String calculateDuration(String startTime, String endTime) {
    try {
      final start = DateFormat('HH:mm').parse(startTime);
      final end = DateFormat('HH:mm').parse(endTime);
      
      Duration difference;
      if (end.isBefore(start)) {
        // Nếu thời gian kết thúc nhỏ hơn thời gian bắt đầu, giả sử là ngày hôm sau
        final nextDay = end.add(const Duration(days: 1));
        difference = nextDay.difference(start);
      } else {
        difference = end.difference(start);
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
      } else {
        return '$minutes phút';
      }
    } catch (e) {
      print('Error calculating duration: $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả (${dateFormat.format(widget.selectedDate)})'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return const Center(child: Text('Không tìm thấy xe phù hợp.'));
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
                  child: _buildVehicleCard(vehicle),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final priceFormatted = NumberFormat("#,###", "vi_VN").format(vehicle.price);
    final duration = calculateDuration(vehicle.startTime, vehicle.endTime);
    final availableSeats = _availableSeats[vehicle.id] ?? 0;

    return Ticket(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 253, 109, 37),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      vehicle.vehicleType?.nameType ?? 'Loại xe',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'còn $availableSeats chỗ',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        vehicle.startTime,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Khởi hành',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.yellow[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 180,
                        height: 1,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      Text(
                        vehicle.endTime,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Đến nơi',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.trip?.startLocation ?? '---',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          vehicle.trip?.destination ?? '---',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.trip?.vRouter ?? '',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$priceFormatted đ',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== Ticket & TicketClipper giữ nguyên =====================

class Ticket extends StatelessWidget {
  final double margin;
  final double borderRadius;
  final double clipRadius;
  final double smallClipRadius;
  final int numberOfSmallClips;
  final Widget child;

  const Ticket({
    Key? key,
    this.margin = 20,
    this.borderRadius = 10,
    this.clipRadius = 12.5,
    this.smallClipRadius = 5,
    this.numberOfSmallClips = 13,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final ticketWidth = screenSize.width - margin * 2;
    final ticketHeight = ticketWidth * 0.6;

    return Container(
      width: ticketWidth,
      height: ticketHeight,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 8),
            color: Colors.black.withOpacity(0.1),
            blurRadius: 37,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipPath(
        clipper: TicketClipper(
          borderRadius: borderRadius,
          clipRadius: clipRadius,
          smallClipRadius: smallClipRadius,
          numberOfSmallClips: numberOfSmallClips,
        ),
        child: Container(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  static const double clipPadding = 18;
  final double borderRadius;
  final double clipRadius;
  final double smallClipRadius;
  final int numberOfSmallClips;

  const TicketClipper({
    required this.borderRadius,
    required this.clipRadius,
    required this.smallClipRadius,
    required this.numberOfSmallClips,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    final clipCenterY = size.height * 0.65 + clipRadius;

    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    ));

    final clipPath = Path();
    clipPath.addOval(Rect.fromCircle(center: Offset(0, clipCenterY), radius: clipRadius));
    clipPath.addOval(Rect.fromCircle(center: Offset(size.width, clipCenterY), radius: clipRadius));

    final clipContainerSize = size.width - clipRadius * 2 - clipPadding * 2;
    final smallClipSize = smallClipRadius * 2;
    final smallClipBoxSize = clipContainerSize / numberOfSmallClips;
    final smallClipPadding = (smallClipBoxSize - smallClipSize) / 2;
    final smallClipStart = clipRadius + clipPadding;

    final smallClipOffsets = List.generate(numberOfSmallClips, (index) {
      final boxX = smallClipStart + smallClipBoxSize * index;
      return Rect.fromLTWH(boxX + smallClipPadding, clipCenterY - 2, smallClipSize, 4);
    });

    for (final rect in smallClipOffsets) {
      clipPath.addRect(rect);
    }

    final ticketPath = Path.combine(
      PathOperation.reverseDifference,
      clipPath,
      path,
    );

    return ticketPath;
  }

  @override
  bool shouldReclip(TicketClipper old) =>
      old.borderRadius != borderRadius ||
      old.clipRadius != clipRadius ||
      old.smallClipRadius != smallClipRadius ||
      old.numberOfSmallClips != numberOfSmallClips;
}
