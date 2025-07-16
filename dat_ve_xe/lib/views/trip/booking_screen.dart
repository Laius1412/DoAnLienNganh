import 'package:flutter/material.dart';
import 'package:dat_ve_xe/models/vehicle_model.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dat_ve_xe/views/trip/payment_screen.dart';
import 'package:dat_ve_xe/models/stop_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:dat_ve_xe/models/seat_position_model.dart';

class BookingScreen extends StatefulWidget {
  final Vehicle vehicle;
  final String startLocation;
  final String destination;
  final DateTime selectedDate;

  const BookingScreen({
    Key? key,
    required this.vehicle,
    required this.startLocation,
    required this.destination,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  final Set<String> _selectedSeats = {};
  final Set<String> _bookedSeats = {};
  bool _isLoading = false;
  bool _isInitializing = true;
  int _step = 1; // 1: chọn ghế, 2: chọn điểm lên/xuống
  
  // Danh sách các điểm dừng (Stop)
  List<Stop> get _stops => widget.vehicle.trip?.stops ?? [];

  String? _selectedStartCity;
  String? _selectedStartLocation;
  String? _selectedEndCity;
  String? _selectedEndLocation;

  final Map<String, Timer> _holdSeatTimers = {};

  @override
  void initState() {
    super.initState();
    _loadBookedSeats();
    // Set initial locations from widget, ensuring they exist in the list
    final stops = _stops;
    if (stops.isNotEmpty) {
      _selectedStartCity = stops.first.city;
      _selectedEndCity = stops.last.city;
      _selectedStartLocation = stops.first.locations.isNotEmpty ? stops.first.locations.first : null;
      _selectedEndLocation = stops.last.locations.isNotEmpty ? stops.last.locations.first : null;
    }
  }

  Future<void> _loadBookedSeats() async {
    try {
      final bookedSeats = await _bookingService.getBookedSeatsForVehicle(
        widget.vehicle.id,
        widget.selectedDate,
      );
      
      setState(() {
        _bookedSeats.clear();
        _bookedSeats.addAll(bookedSeats);
        _isInitializing = false;
      });
    } catch (e) {
      print('Error loading booked seats: $e');
      setState(() => _isInitializing = false);
    }
  }

  // Sinh danh sách ghế tự động chia 2 tầng, mã ghế theo dòng
  List<Map<String, String>> _generateSeatsList() {
    final seatCount = widget.vehicle.vehicleType?.seatCount ?? 0;
    final nameType = widget.vehicle.vehicleType?.nameType?.toLowerCase() ?? '';
    int columns = 2;
    if (nameType.contains('giường nằm') && (seatCount == 34 || seatCount == 38)) {
      columns = 3;
    }
    // Chia đều cho 2 tầng
    int floor1Count = (seatCount / 2).ceil();
    int floor2Count = seatCount - floor1Count;
    List<Map<String, String>> seats = [];
    // Tầng 1
    int rows1 = (floor1Count / columns).ceil();
    int seatNum = 1;
    for (int r = 0; r < rows1; r++) {
      for (int c = 0; c < columns; c++) {
        if (seatNum > floor1Count) break;
        String colChar = String.fromCharCode(65 + c); // 65 = 'A'
        String code = '$colChar${r + 1}-T1';
        seats.add({'code': code, 'floor': '1'});
        seatNum++;
      }
    }
    // Tầng 2
    int rows2 = (floor2Count / columns).ceil();
    seatNum = 1;
    for (int r = 0; r < rows2; r++) {
      for (int c = 0; c < columns; c++) {
        if (seatNum > floor2Count) break;
        String colChar = String.fromCharCode(65 + c); // 65 = 'A'

        String code = '$colChar${r + 1}-T2';
        seats.add({'code': code, 'floor': '2'});
        seatNum++;
      }
    }
    return seats;
  }

  // Tính tổng tiền
  int get _totalPrice => _selectedSeats.length * widget.vehicle.price;

  // Kiểm tra xem ghế có thể chọn được không
  bool _canSelectSeat(String seatNumber) {
    return !_bookedSeats.contains(seatNumber);
  }

  // Xử lý đặt vé
  Future<void> _handleBooking() async {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ghế')),
      );
      return;
    }

    if (_selectedStartLocation == null || _selectedEndLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn điểm đón và điểm trả')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để đặt vé')),
        );
        return;
      }

      final seatDetails = _selectedSeats.map((seat) => <String, dynamic>{
        'seatPosition': {
          'numberSeat': seat,
          'isBooked': true,
        },
        'vehicle': widget.vehicle,
      }).toList();

      final bookingId = await _bookingService.createBooking(
        userId: user.uid,
        startLocationBooking: '${_selectedStartLocation!} (${_selectedStartCity ?? ''})',
        endLocationBooking: '${_selectedEndLocation!} (${_selectedEndCity ?? ''})',
        totalPrice: _totalPrice,
        seatDetails: seatDetails,
        selectedDate: widget.selectedDate,
      );

      if (bookingId != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                bookingId: bookingId,
                totalAmount: _totalPrice,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt vé thất bại. Vui lòng thử lại!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Bước 2: Chọn điểm đón/trả (nested city/location)
  void _showLocationSelectionSheet(bool isStartLocation) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? Colors.grey[900] : const Color(0xFFFFF3E8);
    final headerBg = isDark ? Colors.orange[900] : const Color.fromARGB(255, 253, 109, 37);
    final citySelected = isDark ? Colors.orange[200] : const Color.fromARGB(255, 253, 109, 37);
    final cityUnselected = isDark ? Colors.white : Colors.black87;
    final cityBgSelected = isDark ? Colors.orange[900]!.withOpacity(0.13) : const Color.fromARGB(255, 253, 109, 37).withOpacity(0.1);
    final cityBgUnselected = Colors.transparent;
    final locationSelected = isDark ? Colors.orange[200] : const Color.fromARGB(255, 253, 109, 37);
    final locationUnselected = isDark ? Colors.white : Colors.black87;
    final locationBgSelected = isDark ? Colors.orange[900]!.withOpacity(0.13) : const Color.fromARGB(255, 253, 109, 37).withOpacity(0.1);
    final locationBgUnselected = Colors.transparent;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 2/3,
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isStartLocation ? 'Chọn tỉnh/thành điểm đón' : 'Chọn tỉnh/thành điểm trả',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Row(
                    children: [
                      // Danh sách tỉnh/thành
                      Container(
                        width: 140,
                        color: isDark ? Colors.grey[850] : Colors.white,
                        child: ListView.builder(
                          itemCount: _stops.length,
                          itemBuilder: (context, index) {
                            final stop = _stops[index];
                            final isSelected = (isStartLocation
                                ? stop.city == _selectedStartCity
                                : stop.city == _selectedEndCity);
                            return Material(
                              color: isSelected ? cityBgSelected : cityBgUnselected,
                              child: ListTile(
                                title: Text(
                                  stop.city,
                                  style: TextStyle(
                                    color: isSelected ? citySelected : cityUnselected,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                onTap: () {
                                  setModalState(() {
                                    if (isStartLocation) {
                                      _selectedStartCity = stop.city;
                                      _selectedStartLocation = stop.locations.isNotEmpty ? stop.locations.first : null;
                                    } else {
                                      _selectedEndCity = stop.city;
                                      _selectedEndLocation = stop.locations.isNotEmpty ? stop.locations.first : null;
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      // Danh sách điểm đón/trả chi tiết
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final selectedStop = isStartLocation
                                ? _stops.firstWhere((s) => s.city == _selectedStartCity, orElse: () => _stops.first)
                                : _stops.firstWhere((s) => s.city == _selectedEndCity, orElse: () => _stops.last);
                            final locations = selectedStop.locations;
                            final selectedLocation = isStartLocation ? _selectedStartLocation : _selectedEndLocation;
                            return ListView.builder(
                              itemCount: locations.length,
                              itemBuilder: (context, index) {
                                final location = locations[index];
                                final isSelected = location == selectedLocation;
                                return Material(
                                  color: isSelected ? locationBgSelected : locationBgUnselected,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: isSelected ? locationSelected : (isDark ? Colors.grey[400] : Colors.grey),
                                    ),
                                    title: Text(
                                      location,
                                      style: TextStyle(
                                        color: isSelected ? locationSelected : locationUnselected,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        if (isStartLocation) {
                                          _selectedStartLocation = location;
                                        } else {
                                          _selectedEndLocation = location;
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getOrCreateSeatIdByCode(String code) async {
    final dateStr = "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";
    final query = await FirebaseFirestore.instance
        .collection('seatPositions')
        .where('vehicleId', isEqualTo: widget.vehicle.id)
        .where('date', isEqualTo: dateStr)
        .where('numberSeat', isEqualTo: code)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    } else {
      // Tạo mới seatPosition nếu chưa có
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final docRef = await FirebaseFirestore.instance.collection('seatPositions').add({
        'vehicleId': widget.vehicle.id,
        'date': dateStr,
        'numberSeat': code,
        'isBooked': false,
        'holdBy': user.uid,
        'holdUntil': DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
      });
      return docRef.id;
    }
  }

  Future<void> _handleSelectSeat(String code) async {
    if (_selectedSeats.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chỉ có thể đặt tối đa 4 vé mỗi lần!')),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để chọn ghế!')),
      );
      return;
    }
    final seatId = await _getOrCreateSeatIdByCode(code);
    if (seatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy hoặc tạo được ghế $code!')),
      );
      return;
    }
    final success = await _bookingService.holdSeat(seatId, user.uid);
    if (success) {
      setState(() {
        _selectedSeats.add(code);
      });
      // Tạo timer tự động release sau 1 phút nếu không thao tác
      _holdSeatTimers[code]?.cancel();
      _holdSeatTimers[code] = Timer(const Duration(minutes: 1), () async {
        await _bookingService.releaseSeat(seatId, user.uid);
        setState(() {
          _selectedSeats.remove(code);
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ghế $code đang được giữ bởi người khác!')),
      );
    }
  }

  Future<void> _handleDeselectSeat(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final seatId = await _getOrCreateSeatIdByCode(code);
    if (seatId != null) {
      await _bookingService.releaseSeat(seatId, user.uid);
    }
    _holdSeatTimers[code]?.cancel();
    setState(() {
      _selectedSeats.remove(code);
    });
  }

  @override
  void dispose() {
    for (var timer in _holdSeatTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Stream<List<SeatPosition>> seatStream() {
    final dateStr = "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}";
    return FirebaseFirestore.instance
        .collection('seatPositions')
        .where('vehicleId', isEqualTo: widget.vehicle.id)
        .where('date', isEqualTo: dateStr)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SeatPosition.fromMap(doc.id, doc.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900] : const Color.fromARGB(255, 255, 243, 232);
    final borderColor = isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = isDark ? Colors.white : const Color.fromARGB(255, 253, 109, 37);
    final subTextColor = isDark ? Colors.white70 : Colors.black87;
    final seatBookedColor = isDark ? Colors.grey[700]! : Colors.grey[700]!;
    final seatSelectedColor = isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    final seatEmptyColor = isDark ? Colors.grey[900]! : Colors.white;
    final seatBorderColor = isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    final buttonBg = isDark ? Colors.orange[900] : const Color.fromARGB(255, 253, 109, 37);
    final buttonText = Colors.white;
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Đặt vé', style: TextStyle(color: textColor)),
          backgroundColor: buttonBg,
          foregroundColor: textColor,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final seatsList = _generateSeatsList();
    final nameType = widget.vehicle.vehicleType?.nameType?.toLowerCase() ?? '';
    final seatCount = widget.vehicle.vehicleType?.seatCount ?? 0;
    final columns = (nameType.contains('giường nằm') && (seatCount == 34 || seatCount == 38)) ? 3 : 2;
    final seatsFloor1 = seatsList.where((s) => s['floor'] == '1').toList();
    final seatsFloor2 = seatsList.where((s) => s['floor'] == '2').toList();

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Đặt vé', style: TextStyle(color: textColor)),
        backgroundColor: buttonBg,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<List<SeatPosition>>(
        stream: seatStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final seatPositions = snapshot.data!;
          final seatStatusMap = { for (var s in seatPositions) s.numberSeat: s };

          bool isSeatLocked(String code) {
            final seat = seatStatusMap[code];
            if (seat == null) return false;
            final now = DateTime.now();
            if (seat.isBooked) return true;
            if (seat.holdBy != null && seat.holdUntil != null) {
              final holdUntil = DateTime.tryParse(seat.holdUntil!);
              if (holdUntil != null && holdUntil.isAfter(now)) {
                if (user == null || seat.holdBy != user.uid) {
                  return true; // đang bị giữ bởi người khác
                }
              }
            }
            return false;
          }

          bool isSeatHeldByMe(String code) {
            final seat = seatStatusMap[code];
            if (seat == null || user == null) return false;
            final now = DateTime.now();
            if (seat.holdBy == user.uid && seat.holdUntil != null) {
              final holdUntil = DateTime.tryParse(seat.holdUntil!);
              if (holdUntil != null && holdUntil.isAfter(now)) {
                return true;
              }
            }
            return false;
          }

          return Column(
            children: [
              // Thông tin chuyến đi
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor, // màu nền bên trong
                  border: Border.all(
                    color: borderColor, // viền cam
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.vehicle.trip?.nameTrip}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: labelColor),
                        const SizedBox(width: 8),
                        Text(
                          'Ngày đi: ${dateFormat.format(widget.selectedDate)}',
                          style: TextStyle(fontSize: 16, color: subTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: labelColor),
                        const SizedBox(width: 8),
                        Text(
                          'Giờ: ${widget.vehicle.startTime} - ${widget.vehicle.endTime}',
                          style: TextStyle(fontSize: 16, color: subTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.directions_bus, color: labelColor),
                        const SizedBox(width: 8),
                        Text(
                          'Loại xe: ${widget.vehicle.vehicleType?.nameType} (${widget.vehicle.vehicleType?.seatCount} chỗ)',
                          style: TextStyle(fontSize: 16, color: subTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: labelColor),
                        const SizedBox(width: 8),
                        Text(
                          'Giá vé: ${NumberFormat("#,###", "vi_VN").format(widget.vehicle.price)}đ/ghế',
                          style: TextStyle(fontSize: 16, color: subTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sơ đồ ghế 2 tầng (Bước 1)
              if (_step == 1)
                Expanded(
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 11),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(
                          color: borderColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.orange[900]!.withOpacity(0.08) : Colors.orange.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Chú thích
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSeatLegend(seatBookedColor, 'Đã bán'),
                                const SizedBox(width: 16),
                                _buildSeatLegend(seatSelectedColor, 'Đang chọn'),
                                const SizedBox(width: 16),
                                _buildSeatLegend(seatEmptyColor, 'Giường trống', border: seatBorderColor),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text('Tầng 1', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Tầng 2', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tầng 1
                              Expanded(
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 6,
                                  ),
                                  itemCount: seatsFloor1.length,
                                  itemBuilder: (context, index) {
                                    final seat = seatsFloor1[index];
                                    final code = seat['code']!;
                                    final isBooked = isSeatLocked(code);
                                    final isSelected = _selectedSeats.contains(code);
                                    final isHeldByMe = isSeatHeldByMe(code);
                                    return _buildCustomSeatButton(code, isSelected, isBooked, isHeldByMe);
                                  },
                                ),
                              ),
                              // Đường kẻ phân tách
                              Container(
                                width: 2,
                                height: 400,
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 253, 91, 9).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 253, 91, 9).withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              // Tầng 2
                              Expanded(
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 6,
                                  ),
                                  itemCount: seatsFloor2.length,
                                  itemBuilder: (context, index) {
                                    final seat = seatsFloor2[index];
                                    final code = seat['code']!;
                                    final isBooked = isSeatLocked(code);
                                    final isSelected = _selectedSeats.contains(code);
                                    final isHeldByMe = isSeatHeldByMe(code);
                                    return _buildCustomSeatButton(code, isSelected, isBooked, isHeldByMe);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Bước 2: Chọn điểm đón/trả
              if (_step == 2)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.orange[900]!.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chọn điểm đón và trả khách',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _showLocationSelectionSheet(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? Colors.grey[850] : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: labelColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedStartLocation != null && _selectedStartCity != null
                                        ? '${_selectedStartLocation!} (${_selectedStartCity!})'
                                        : 'Chọn điểm đón',
                                    style: TextStyle(
                                      color: _selectedStartLocation != null ? textColor : (isDark ? Colors.white54 : Colors.grey),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _showLocationSelectionSheet(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? Colors.grey[850] : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: labelColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedEndLocation != null && _selectedEndCity != null
                                        ? '${_selectedEndLocation!} (${_selectedEndCity!})'
                                        : 'Chọn điểm trả',
                                    style: TextStyle(
                                      color: _selectedEndLocation != null ? textColor : (isDark ? Colors.white54 : Colors.grey),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom bar
              if ((_step == 1 && _selectedSeats.isNotEmpty) || _step == 2)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.orange[900]!.withOpacity(0.13) : Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tổng tiền:',
                              style: TextStyle(
                                fontSize: 20,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${NumberFormat("#,###", "vi_VN").format(_totalPrice)}đ',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: labelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_step == 1)
                        ElevatedButton(
                          onPressed: _selectedSeats.isNotEmpty && !_isLoading
                              ? () {
                                  setState(() {
                                    _step = 2;
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBg,
                            foregroundColor: buttonText,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(120, 54),
                          ),
                          child: const Text(
                            'Tiếp tục',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (_step == 2)
                        ElevatedButton(
                          onPressed: (_selectedStartLocation != null && _selectedEndLocation != null)
                              ? (_isLoading ? null : _handleBooking)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBg,
                            foregroundColor: buttonText,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(120, 54),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Đặt vé',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Widget ghế mới
  Widget _buildCustomSeatButton(String code, bool isSelected, bool isBooked, [bool isHeldByMe = false]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final seatBookedColor = isDark ? Colors.grey[700]! : Colors.grey[700]!;
    final seatSelectedColor = isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    final seatEmptyColor = isDark ? Colors.grey[900]! : Colors.white;
    final seatBorderColor = isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    Color seatColor;
    if (isBooked) {
      seatColor = seatBookedColor;
    } else if (isSelected) {
      seatColor = seatSelectedColor;
    } else if (isHeldByMe) {
      seatColor = isDark ? Colors.blue[700]! : Colors.blue[200]!;
    } else {
      seatColor = seatEmptyColor;
    }
    return InkWell(
      onTap: isBooked
          ? null
          : () async {
              if (isSelected) {
                await _handleDeselectSeat(code);
              } else {
                await _handleSelectSeat(code);
              }
            },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: seatColor,
          border: Border.all(
            color: isBooked
                ? seatBookedColor
                : isSelected
                    ? seatSelectedColor
                    : seatBorderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: isBooked
              ? const Icon(Icons.close, color: Colors.white, size: 16)
              : Text(
                  code,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // Sửa lại chú thích để hỗ trợ viền
  Widget _buildSeatLegend(Color color, String label, {Color? border}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: border ?? color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }
} 