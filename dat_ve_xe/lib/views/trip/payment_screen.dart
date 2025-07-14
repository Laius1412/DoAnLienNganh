import 'package:flutter/material.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:dat_ve_xe/models/booking_model.dart';
import 'dart:async';
import 'bank_transfer_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final int totalAmount;

  const PaymentScreen({
    Key? key,
    required this.bookingId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;
  bool _isPaymentSuccessful = false;
  DateTime? _paymentDeadline;
  Booking? _booking;
  Timer? _timer;
  String _remainingTime = '05:00';

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Set initial deadline to 5 minutes from now
    _paymentDeadline = DateTime.now().add(const Duration(minutes: 5));
    
    // Update timer every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      final now = DateTime.now();
      final difference = _paymentDeadline!.difference(now);
      
      if (difference.isNegative) {
        _timer?.cancel();
        setState(() => _remainingTime = '00:00');
        _handleTimeout();
        return;
      }
      
      final minutes = difference.inMinutes;
      final seconds = difference.inSeconds % 60;
      setState(() {
        _remainingTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

  Future<void> _handleTimeout() async {
    try {
      // Cancel the booking
      final success = await _bookingService.cancelBooking(widget.bookingId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hết thời gian thanh toán. Đơn hàng đã bị hủy.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể hủy đơn hàng. Vui lòng thử lại.')),
          );
        }
        // Navigate back to home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Error handling timeout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xảy ra lỗi khi hủy đơn hàng.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _loadBookingDetails() async {
    setState(() => _isLoading = true);
    try {
      final booking = await _bookingService.getBookingById(widget.bookingId);
      if (booking != null) {
        setState(() {
          _booking = booking;
          _paymentDeadline = booking.paymentDeadline;
        });
      }
    } catch (e) {
      print('Error loading booking details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);
    try {
      final success = await _bookingService.confirmPayment(widget.bookingId);
      if (success) {
        _timer?.cancel();
        setState(() => _isPaymentSuccessful = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán thành công!')),
          );
          // Navigate back to home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán thất bại. Vui lòng thử lại!')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment deadline countdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Thời gian còn lại: $_remainingTime',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Trip Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 243, 232),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color.fromARGB(255, 253, 109, 37),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin chuyến đi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 253, 109, 37),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_booking != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.directions_bus, color: Color.fromARGB(255, 253, 109, 37)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _booking!.seats.isNotEmpty && _booking!.seats[0].vehicle?.trip != null
                                      ? _booking!.seats[0].vehicle!.trip!.nameTrip
                                      : 'N/A',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color.fromARGB(255, 253, 109, 37)),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_booking!.createDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Color.fromARGB(255, 253, 109, 37)),
                              const SizedBox(width: 8),
                              Text(
                                _booking!.seats.isNotEmpty && _booking!.seats[0].vehicle != null
                                    ? '${_booking!.seats[0].vehicle!.startTime} - ${_booking!.seats[0].vehicle!.endTime}'
                                    : 'N/A',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Color.fromARGB(255, 253, 109, 37)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Điểm đón: ${_booking!.startLocationBooking}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Color.fromARGB(255, 253, 109, 37)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Điểm trả: ${_booking!.endLocationBooking}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.event_seat, color: Color.fromARGB(255, 253, 109, 37)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ghế: ${_booking!.seats.map((s) => s.seatPosition?.numberSeat ?? '').join(", ")}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment amount
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Số tiền thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${NumberFormat("#,###", "vi_VN").format(widget.totalAmount)}đ',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 253, 109, 37),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment methods
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentMethod(
                    icon: Icons.credit_card,
                    title: 'Thẻ tín dụng/ghi nợ (Đang bảo trì)',
                    subtitle: 'Thanh toán qua thẻ Visa, Mastercard',
                  ),
                  _buildPaymentMethod(
                    icon: Icons.account_balance,
                    title: 'Chuyển khoản ngân hàng',
                    subtitle: 'Chuyển khoản qua ngân hàng',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BankTransferScreen(
                            bookingId: widget.bookingId,
                            totalAmount: widget.totalAmount,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildPaymentMethod(
                    icon: Icons.qr_code,
                    title: 'Ví điện tử (Đang bảo trì)',
                    subtitle: 'Thanh toán qua Momo, ZaloPay',
                  ),
                  const SizedBox(height: 32),

                  // Payment button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                              'Thanh toán ngay',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 253, 109, 37)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap ?? _handlePayment,
      ),
    );
  }
} 