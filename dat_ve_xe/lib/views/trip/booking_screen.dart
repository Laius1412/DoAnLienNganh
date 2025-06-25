import 'package:flutter/material.dart';
import 'package:dat_ve_xe/models/vehicle_model.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dat_ve_xe/models/booking_model.dart';
import 'package:dat_ve_xe/views/trip/payment_screen.dart';
import 'package:dat_ve_xe/models/stop_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 2/3,
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF3E8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 253, 109, 37),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: _stops.length,
                          itemBuilder: (context, index) {
                            final stop = _stops[index];
                            final isSelected = (isStartLocation
                                ? stop.city == _selectedStartCity
                                : stop.city == _selectedEndCity);
                            return Material(
                              color: isSelected ? const Color.fromARGB(255, 253, 109, 37).withOpacity(0.1) : Colors.transparent,
                              child: ListTile(
                                title: Text(
                                  stop.city,
                                  style: TextStyle(
                                    color: isSelected ? const Color.fromARGB(255, 253, 109, 37) : Colors.black87,
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
                                  color: isSelected ? const Color.fromARGB(255, 253, 109, 37).withOpacity(0.1) : Colors.transparent,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: isSelected ? const Color.fromARGB(255, 253, 109, 37) : Colors.grey,
                                    ),
                                    title: Text(
                                      location,
                                      style: TextStyle(
                                        color: isSelected ? const Color.fromARGB(255, 253, 109, 37) : Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Đặt vé'),
          backgroundColor: const Color.fromARGB(255, 253, 109, 37),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Lấy danh sách ghế động
    final seatsList = _generateSeatsList();
    final nameType = widget.vehicle.vehicleType?.nameType?.toLowerCase() ?? '';
    final seatCount = widget.vehicle.vehicleType?.seatCount ?? 0;
    final columns = (nameType.contains('giường nằm') && (seatCount == 34 || seatCount == 38)) ? 3 : 2;
    final seatsFloor1 = seatsList.where((s) => s['floor'] == '1').toList();
    final seatsFloor2 = seatsList.where((s) => s['floor'] == '2').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt vé'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Thông tin chuyến đi
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 243, 232), // màu nền bên trong
              border: Border.all(
                color: const Color.fromARGB(255, 253, 109, 37), // viền cam
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 253, 109, 37),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color.fromARGB(255, 253, 109, 37)),
                    const SizedBox(width: 8),
                    Text(
                      'Ngày đi: ${dateFormat.format(widget.selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Color.fromARGB(255, 253, 109, 37)),
                    const SizedBox(width: 8),
                    Text(
                      'Giờ: ${widget.vehicle.startTime} - ${widget.vehicle.endTime}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.directions_bus, color: Color.fromARGB(255, 253, 109, 37)),
                    const SizedBox(width: 8),
                    Text(
                      'Loại xe: ${widget.vehicle.vehicleType?.nameType} (${widget.vehicle.vehicleType?.seatCount} chỗ)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Color.fromARGB(255, 253, 109, 37)),
                    const SizedBox(width: 8),
                    Text(
                      'Giá vé: ${NumberFormat("#,###", "vi_VN").format(widget.vehicle.price)}đ/ghế',
                      style: const TextStyle(fontSize: 16),
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
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E8), // nền cam nhạt
                    border: Border.all(
                      color: Color.fromARGB(255, 253, 109, 37), // viền cam
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
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
                            _buildSeatLegend(Colors.grey[700]!, 'Đã bán'),
                            const SizedBox(width: 16),
                            _buildSeatLegend(const Color.fromARGB(255, 253, 109, 37), 'Đang chọn'),
                            const SizedBox(width: 16),
                            _buildSeatLegend(Colors.white, 'Giường trống', border: Colors.black),
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
                                final isBooked = _bookedSeats.contains(code);
                                final isSelected = _selectedSeats.contains(code);
                                return _buildCustomSeatButton(code, isSelected, isBooked);
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
                                final isBooked = _bookedSeats.contains(code);
                                final isSelected = _selectedSeats.contains(code);
                                return _buildCustomSeatButton(code, isSelected, isBooked);
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 253, 109, 37), width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn điểm đón và trả khách',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 253, 109, 37),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _showLocationSelectionSheet(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(255, 253, 109, 37),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Color.fromARGB(255, 253, 109, 37)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedStartLocation != null && _selectedStartCity != null
                                    ? '${_selectedStartLocation!} (${_selectedStartCity!})'
                                    : 'Chọn điểm đón',
                                style: TextStyle(
                                  color: _selectedStartLocation != null ? Colors.black : Colors.grey,
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
                            color: const Color.fromARGB(255, 253, 109, 37),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Color.fromARGB(255, 253, 109, 37)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedEndLocation != null && _selectedEndCity != null
                                    ? '${_selectedEndLocation!} (${_selectedEndCity!})'
                                    : 'Chọn điểm trả',
                                style: TextStyle(
                                  color: _selectedEndLocation != null ? Colors.black : Colors.grey,
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
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
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
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${NumberFormat("#,###", "vi_VN").format(_totalPrice)}đ',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 253, 109, 37),
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
                        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
                        foregroundColor: Colors.white,
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
                        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
                        foregroundColor: Colors.white,
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
      ),
    );
  }

  // Widget ghế mới
  Widget _buildCustomSeatButton(String code, bool isSelected, bool isBooked) {
    return InkWell(
      onTap: isBooked
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedSeats.remove(code);
                } else {
                  _selectedSeats.add(code);
                }
              });
            },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey[700]
              : isSelected
                  ? const Color.fromARGB(255, 253, 109, 37)
                  : Colors.white,
          border: Border.all(
            color: isBooked
                ? Colors.grey[700]!
                : isSelected
                    ? const Color.fromARGB(255, 253, 109, 37)
                    : const Color.fromARGB(255, 253, 109, 37), // border cam cho ghế trống
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
        Text(label),
      ],
    );
  }
} 