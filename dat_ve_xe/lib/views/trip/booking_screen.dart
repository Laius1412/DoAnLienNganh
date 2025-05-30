import 'package:flutter/material.dart';
import 'package:dat_ve_xe/models/vehicle_model.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dat_ve_xe/models/booking_model.dart';

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
  final int _seatsPerRow = 2;
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadBookedSeats();
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

  // Tạo danh sách ghế dựa trên số ghế của xe
  List<String> _generateSeatList() {
    final seatCount = widget.vehicle.vehicleType?.seatCount ?? 0;
    return List.generate(seatCount, (index) => (index + 1).toString());
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
        startLocationBooking: widget.startLocation,
        endLocationBooking: widget.destination,
        totalPrice: _totalPrice,
        seatDetails: seatDetails,
        selectedDate: widget.selectedDate,
      );

      if (bookingId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt vé thành công!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt vé thất bại. Vui lòng thử lại!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seats = _generateSeatList();
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
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.vehicle.trip?.nameTrip}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ngày đi: ${dateFormat.format(widget.selectedDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Giờ: ${widget.vehicle.startTime} - ${widget.vehicle.endTime}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Loại xe: ${widget.vehicle.vehicleType?.nameType} (${widget.vehicle.vehicleType?.seatCount} chỗ)',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Giá vé: ${NumberFormat("#,###", "vi_VN").format(widget.vehicle.price)}đ/ghế',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Sơ đồ ghế
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Chọn ghế',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Hiển thị chú thích
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSeatLegend(Colors.grey[300]!, 'Ghế trống'),
                      const SizedBox(width: 16),
                      _buildSeatLegend(
                        const Color.fromARGB(255, 253, 109, 37),
                        'Ghế đã chọn',
                      ),
                      const SizedBox(width: 16),
                      _buildSeatLegend(Colors.grey[700]!, 'Ghế đã đặt'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Hiển thị sơ đồ ghế
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _seatsPerRow,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: seats.length,
                    itemBuilder: (context, index) {
                      final seat = seats[index];
                      final isSelected = _selectedSeats.contains(seat);
                      final isBooked = _bookedSeats.contains(seat);
                      return _buildSeatButton(seat, isSelected, isBooked);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar hiển thị tổng tiền và nút đặt vé
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
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
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${NumberFormat("#,###", "vi_VN").format(_totalPrice)}đ',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 253, 109, 37),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 253, 109, 37),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Đặt vé',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatButton(String seatNumber, bool isSelected, bool isBooked) {
    return InkWell(
      onTap: isBooked ? null : () {
        setState(() {
          if (isSelected) {
            _selectedSeats.remove(seatNumber);
          } else {
            _selectedSeats.add(seatNumber);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey[700]
              : isSelected
                  ? const Color.fromARGB(255, 253, 109, 37)
                  : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Ghế $seatNumber',
            style: TextStyle(
              color: isBooked || isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
} 