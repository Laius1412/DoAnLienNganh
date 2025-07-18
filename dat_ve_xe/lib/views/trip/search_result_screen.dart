import 'package:flutter/material.dart';
import 'package:dat_ve_xe/models/vehicle_model.dart';
import 'package:dat_ve_xe/server/vehicle_service.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:intl/intl.dart';
import 'booking_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SearchResultScreen extends StatefulWidget {
  final String startLocation;
  final String destination;
  final DateTime selectedDate;
  final bool searchByStopsStart;
  final bool searchByStopsEnd;

  const SearchResultScreen({
    Key? key,
    required this.startLocation,
    required this.destination,
    required this.selectedDate,
    this.searchByStopsStart = false,
    this.searchByStopsEnd = false,
  }) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final VehicleService _vehicleService = VehicleService();
  final BookingService _bookingService = BookingService();
  late Future<List<Vehicle>> _vehicleFuture;
  Map<String, int> _availableSeats = {};

  // Các biến filter sẽ khởi tạo động theo l10n
  String? _sortOption;
  String? _timeFilter;
  String? _vehicleTypeFilter;
  List<String>? _vehicleTypes;

  bool _didLoadVehicles = false;

  @override
  void initState() {
    super.initState();
    // Không gọi _loadVehicles ở đây!
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _sortOption ??= l10n.earliestTime;
    _timeFilter ??= l10n.all;
    _vehicleTypeFilter ??= l10n.all;
    _vehicleTypes ??= [l10n.all];

    if (!_didLoadVehicles) {
      _didLoadVehicles = true;
      _loadVehicles();
    }
  }

  Future<void> _loadVehicles() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _vehicleFuture = _vehicleService.searchVehiclesByLocation(
        startLocation: widget.startLocation,
        destination: widget.destination,
        searchByStopsStart: widget.searchByStopsStart,
        searchByStopsEnd: widget.searchByStopsEnd,
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
        // Cập nhật danh sách loại xe
        final types = vehicles.map((v) => v.vehicleType?.nameType ?? '').toSet().toList();
        types.removeWhere((e) => e.isEmpty);
        setState(() {
          _vehicleTypes = [l10n.all, ...types];
        });
        // Sắp xếp mặc định theo giờ khởi hành
        vehicles.sort((a, b) {
          final timeA = DateFormat('HH:mm').parse(a.startTime);
          final timeB = DateFormat('HH:mm').parse(b.startTime);
          return timeA.compareTo(timeB);
        });
        return vehicles;
      });
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
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final ticketBg = isDark ? Colors.orange[900] : const Color.fromARGB(255, 253, 109, 37);

    // Đảm bảo filter luôn đồng bộ với l10n khi build
    _sortOption ??= l10n.earliestTime;
    _timeFilter ??= l10n.all;
    _vehicleTypeFilter ??= l10n.all;
    _vehicleTypes ??= [l10n.all];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('${l10n.tripListTitle} (${dateFormat.format(widget.selectedDate)})'),
        backgroundColor: ticketBg,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // UI mới: 3 nút lớn, mỗi nút mở BottomSheet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    icon: Icons.sort,
                    label: l10n.sort,
                    value: _sortOption!,
                    onTap: () => _showFilterBottomSheet(
                      context,
                      title: l10n.sort,
                      options: [l10n.earliestTime, l10n.mostAvailableSeats, l10n.lowestPrice],
                      current: _sortOption!,
                      onSelected: (val) => setState(() => _sortOption = val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterButton(
                    icon: Icons.access_time,
                    label: l10n.timeRange,
                    value: _timeFilter!,
                    onTap: () => _showFilterBottomSheet(
                      context,
                      title: l10n.timeRange,
                      options: [l10n.all, l10n.time0_12, l10n.time12_19, l10n.time19_24],
                      current: _timeFilter!,
                      onSelected: (val) => setState(() => _timeFilter = val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilterButton(
                    icon: Icons.directions_bus,
                    label: l10n.vehicleType,
                    value: _vehicleTypeFilter!,
                    onTap: () => _showFilterBottomSheet(
                      context,
                      title: l10n.vehicleType,
                      options: _vehicleTypes!,
                      current: _vehicleTypeFilter!,
                      onSelected: (val) => setState(() => _vehicleTypeFilter = val),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Danh sách xe
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadVehicles,
              child: FutureBuilder<List<Vehicle>>(
                future: _vehicleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('${l10n.error}:  [${snapshot.error}'));
                  }

                  final vehicles = snapshot.data ?? [];

                  if (vehicles.isEmpty) {
                    return Center(child: Text(l10n.noVehicleFound));
                  }

                  // Áp dụng lọc khung giờ
                  List<Vehicle> filtered = vehicles.where((vehicle) {
                    // Lọc theo loại xe
                    if (_vehicleTypeFilter != l10n.all && (vehicle.vehicleType?.nameType ?? '') != _vehicleTypeFilter) {
                      return false;
                    }
                    // Lọc theo khung giờ
                    if (_timeFilter != l10n.all) {
                      final time = DateFormat('HH:mm').parse(vehicle.startTime);
                      final hour = time.hour;
                      if (_timeFilter == l10n.time0_12 && (hour < 0 || hour >= 12)) return false;
                      if (_timeFilter == l10n.time12_19 && (hour < 12 || hour >= 19)) return false;
                      if (_timeFilter == l10n.time19_24 && (hour < 19 || hour >= 24)) return false;
                    }
                    // Lọc chuyến đã khởi hành nếu là hôm nay
                    final now = DateTime.now();
                    if (widget.selectedDate.year == now.year &&
                        widget.selectedDate.month == now.month &&
                        widget.selectedDate.day == now.day) {
                      final start = DateFormat('HH:mm').parse(vehicle.startTime);
                      final vehicleDateTime = DateTime(
                        now.year, now.month, now.day, start.hour, start.minute);
                      if (vehicleDateTime.isBefore(now)) return false;
                    }
                    return true;
                  }).toList();

                  // Áp dụng sắp xếp
                  if (_sortOption == l10n.earliestTime) {
                    filtered.sort((a, b) {
                      final timeA = DateFormat('HH:mm').parse(a.startTime);
                      final timeB = DateFormat('HH:mm').parse(b.startTime);
                      return timeA.compareTo(timeB);
                    });
                  } else if (_sortOption == l10n.mostAvailableSeats) {
                    filtered.sort((a, b) {
                      final seatsA = _availableSeats[a.id] ?? 0;
                      final seatsB = _availableSeats[b.id] ?? 0;
                      return seatsB.compareTo(seatsA);
                    });
                  } else if (_sortOption == l10n.lowestPrice) {
                    filtered.sort((a, b) => a.price.compareTo(b.price));
                  }

                  if (filtered.isEmpty) {
                    return Center(child: Text(l10n.noVehicleWithFilter));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final vehicle = filtered[index];
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final priceFormatted = NumberFormat("#,###", "vi_VN").format(vehicle.price);
    final duration = calculateDuration(vehicle.startTime, vehicle.endTime);
    final availableSeats = _availableSeats[vehicle.id] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticketBg = isDark ? Colors.orange[900] : const Color.fromARGB(255, 253, 109, 37);

    return Ticket(
      child: Container(
        decoration: BoxDecoration(
          color: ticketBg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vehicle.startTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Khởi hành',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vehicle.endTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Đến nơi',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          vehicle.trip?.destination ?? '---',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.trip?.vRouter ?? '',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$priceFormatted đ',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 23,
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
    this.numberOfSmallClips = 20,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final ticketWidth = screenSize.width - margin * 2;
    return Container(
      width: ticketWidth,
      // Bỏ height cố định để nội dung tự co giãn
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
  static const double clipPadding = 5;
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

// Thêm widget nút bộ lọc và hàm show bottom sheet

// Nút bộ lọc
class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFd6D25),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Hàm show bottom sheet chọn bộ lọc
void _showFilterBottomSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String current,
  required ValueChanged<String> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFd6D25),
                ),
              ),
            ),
            ...options.map((e) => ListTile(
                  title: Text(e, style: TextStyle(
                    color: e == current ? const Color(0xFFFd6D25) : Colors.black,
                    fontWeight: e == current ? FontWeight.bold : FontWeight.normal,
                  )),
                  trailing: e == current
                      ? const Icon(Icons.check, color: Color(0xFFFd6D25))
                      : null,
                  onTap: () {
                    onSelected(e);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
