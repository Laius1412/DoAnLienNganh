import 'package:flutter/material.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:dat_ve_xe/models/booking_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:dat_ve_xe/views/personal_screen/login_request_card.dart';

class MyTicketScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  const MyTicketScreen({Key? key, required this.onLanguageChanged}) : super(key: key);

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Loading bookings for user: ${user.uid}');
        final bookings = await _bookingService.getUserBookings(user.uid);
        print('Loaded ${bookings.length} bookings');
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      } else {
        print('No user logged in');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải vé: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Đang chờ xác nhận';
      case 'pending_payment':
        return 'Chờ thanh toán';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'pending_payment':
        return Colors.red;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vé của tôi'),
          backgroundColor: const Color.fromARGB(255, 253, 109, 37),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SizedBox(
            width: 400,
            child: LoginRequestCard(
              onLanguageChanged: (Locale locale) {
                widget.onLanguageChanged(locale);
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vé của tôi'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Text(
                    'Bạn chưa có vé nào',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mã vé: ${booking.id.substring(0, 8)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(booking.statusBooking)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getStatusText(booking.statusBooking),
                                      style: TextStyle(
                                        color: _getStatusColor(booking.statusBooking),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (booking.seats.isNotEmpty &&
                                  booking.seats[0].vehicle != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tuyến xe: ${booking.seats[0].vehicle!.trip?.nameTrip ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Biển số xe: ${booking.seats[0].vehicle!.plate}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ghế: ${booking.seats.map((s) => s.seatPosition?.numberSeat ?? '').join(', ')}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ngày đi: ${DateFormat('dd/MM/yyyy').format(booking.createDate)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tổng tiền: ${NumberFormat("#,###", "vi_VN").format(booking.totalPrice)}đ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 253, 109, 37),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
