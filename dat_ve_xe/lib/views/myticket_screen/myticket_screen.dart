import 'package:flutter/material.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:dat_ve_xe/models/booking_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/views/personal_screen/login_request_card.dart';
import 'package:dat_ve_xe/views/myticket_screen/detail_my_tickets.dart';

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
    return list.where((b) {
      final travelDate = b.getTravelDate();
      return travelDate != null &&
          travelDate.year == _selectedDate!.year &&
          travelDate.month == _selectedDate!.month &&
          travelDate.day == _selectedDate!.day;
    }).toList();
  }

  Widget _buildTicketList(List<Booking> tickets) {
    final filteredTickets = _filterByDate(tickets);

    if (filteredTickets.isEmpty) {
      return const Center(child: Text('Không có vé nào', style: TextStyle(fontSize: 16)));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTickets.length,
        itemBuilder: (context, index) {
          final booking = filteredTickets[index];
          final travelDate = booking.getTravelDate();

          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailMyTicket(booking: booking),
                  ),
                );
              },
          child:  Card(
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
                      Text('Mã vé: ${booking.id.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

                  // Body
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
                        Text('Ngày đi: ${travelDate != null ? DateFormat('dd/MM/yyyy').format(travelDate) : 'Không rõ'}'),
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
          ),
          );
        },
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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

      final currentTickets = _bookings.where((b) {
        final travelDate = b.getTravelDate();
        final startTime = b.seats.isNotEmpty ? b.seats[0].vehicle?.startTime : null;
        if (travelDate != null && startTime != null) {
          final fullDateTime = DateTime.parse('${DateFormat('yyyy-MM-dd').format(travelDate)} ${startTime.padLeft(5, '0')}');
          return fullDateTime.isAfter(now);
        }
        return false;
      }).toList();

      final pastTickets = _bookings.where((b) {
        final travelDate = b.getTravelDate();
        final startTime = b.seats.isNotEmpty ? b.seats[0].vehicle?.startTime : null;
        if (travelDate != null && startTime != null) {
          final fullDateTime = DateTime.parse('${DateFormat('yyyy-MM-dd').format(travelDate)} ${startTime.padLeft(5, '0')}');
          return fullDateTime.isBefore(now);
        }
        return false;
      }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text(t.myTickets),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            actions: [
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Xóa ngày đã chọn',
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  tooltip: 'Chọn ngày',
                  onPressed: _pickDate,
                ),
              ],

            
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
