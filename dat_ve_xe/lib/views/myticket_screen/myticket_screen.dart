import 'package:flutter/material.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:dat_ve_xe/models/booking_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/views/personal_screen/login_request_card.dart';

class MyTicketScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  const MyTicketScreen({Key? key, required this.onLanguageChanged}) : super(key: key);

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen> with TickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  User? _currentUser;
  late TabController _tabController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.uid != _currentUser?.uid) {
        _currentUser = user;
        _loadBookings();
      } else if (user == null) {
        setState(() {
          _currentUser = null;
          _bookings = [];
        });
      }
    });
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      if (_currentUser != null) {
        final bookings = await _bookingService.getUserBookings(_currentUser!.uid);
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
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

  List<Booking> _filterByDate(List<Booking> list) {
    if (_selectedDate == null) return list;
    return list.where((b) =>
      b.createDate.year == _selectedDate!.year &&
      b.createDate.month == _selectedDate!.month &&
      b.createDate.day == _selectedDate!.day).toList();
  }

  Widget _buildTicketList(List<Booking> tickets) {
    if (tickets.isEmpty) {
      return const Center(
        child: Text('Không có vé nào', style: TextStyle(fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final booking = tickets[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã vé: ${booking.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(booking.statusBooking).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(booking.statusBooking),
                          style: TextStyle(
                            color: _getStatusColor(booking.statusBooking),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (booking.seats.isNotEmpty && booking.seats[0].vehicle != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tuyến: ${booking.seats[0].vehicle!.trip?.nameTrip ?? 'N/A'}'),
                        const SizedBox(height: 4),
                        Text('Biển số: ${booking.seats[0].vehicle!.plate}'),
                        const SizedBox(height: 4),
                        Text('Ghế: ${booking.seats.map((s) => s.seatPosition?.numberSeat ?? '').join(', ')}'),
                        const SizedBox(height: 4),
                        Text('Ngày đi: ${DateFormat('dd/MM/yyyy').format(booking.createDate)}'),
                        const SizedBox(height: 4),
                        Text(
                          'Tổng tiền: ${NumberFormat("#,###", "vi_VN").format(booking.totalPrice)}đ',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 253, 109, 37),
                            fontWeight: FontWeight.bold,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.myTickets),
          backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        ),
        body: Center(
          child: SizedBox(
            width: 400,
            child: LoginRequestCard(onLanguageChanged: widget.onLanguageChanged),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final currentTickets = _filterByDate(_bookings.where((b) => b.createDate.isAfter(now)).toList());
    final pastTickets = _filterByDate(_bookings.where((b) => b.createDate.isBefore(now)).toList());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: Row(
            children: [
              Expanded(child: Text(t.myTickets)),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 253, 109, 37)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              if (_selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black87,
            indicator: BoxDecoration(
              color: const Color.fromARGB(255, 253, 109, 37),
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Vé hiện tại'),
              Tab(text: 'Vé đã đi'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTicketList(currentTickets),
                  _buildTicketList(pastTickets),
                ],
              ),
      ),
    );
  }
}
