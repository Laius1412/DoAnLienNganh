import 'package:flutter/material.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:dat_ve_xe/models/booking_model.dart';
import 'dart:async';
import 'bank_transfer_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        _remainingTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
            SnackBar(
              content: Text(AppLocalizations.of(context)!.paymentTimeout),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.paymentCancelFailed),
            ),
          );
        }
        // Navigate back to home screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Error handling timeout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.paymentCancelError),
          ),
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
          // Navigate back to home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.paymentFailed),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorWithMessage(e.toString()),
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor =
        isDark ? Colors.orange[200] : const Color.fromARGB(255, 253, 109, 37);
    final borderColor =
        isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    final buttonBg =
        isDark ? Colors.orange[900] : const Color.fromARGB(255, 253, 109, 37);
    final buttonText = Colors.white;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.paymentTitle,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: buttonBg,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body:
          _isLoading
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
                        color: isDark ? Colors.red[900] : Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.red[700]! : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.paymentTimeLeft(_remainingTime),
                            style: TextStyle(
                              color: isDark ? Colors.orange[200] : Colors.red,
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
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.tripInfo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_booking != null) ...[
                            Row(
                              children: [
                                const Icon(
                                  Icons.directions_bus,
                                  color: Color.fromARGB(255, 253, 109, 37),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _booking!.seats.isNotEmpty &&
                                            _booking!.seats[0].vehicle?.trip !=
                                                null
                                        ? _booking!
                                            .seats[0]
                                            .vehicle!
                                            .trip!
                                            .nameTrip
                                        : AppLocalizations.of(
                                          context,
                                        )!.notAvailable,
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
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color.fromARGB(255, 253, 109, 37),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_booking!.createDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color.fromARGB(255, 253, 109, 37),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _booking!.seats.isNotEmpty &&
                                          _booking!.seats[0].vehicle != null
                                      ? '${_booking!.seats[0].vehicle!.startTime} - ${_booking!.seats[0].vehicle!.endTime}'
                                      : AppLocalizations.of(
                                        context,
                                      )!.notAvailable,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 253, 109, 37),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.pickupPoint(
                                      _booking!.startLocationBooking,
                                    ),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 253, 109, 37),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.dropoffPoint(
                                      _booking!.endLocationBooking,
                                    ),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_seat,
                                  color: Color.fromARGB(255, 253, 109, 37),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!.seatsLabel(
                                      _booking!.seats
                                          .map(
                                            (s) =>
                                                s.seatPosition?.numberSeat ??
                                                '',
                                          )
                                          .join(", "),
                                    ),
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
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.paymentAmount,
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${NumberFormat("#,###", "vi_VN").format(widget.totalAmount)}đ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment methods
                    Text(
                      AppLocalizations.of(context)!.paymentMethod,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(
                      icon: Icons.credit_card,
                      title: AppLocalizations.of(context)!.creditCard,
                      subtitle:
                          AppLocalizations.of(context)!.creditCardSubtitle,
                      enabled: false,
                    ),
                    _buildPaymentMethod(
                      icon: Icons.account_balance,
                      title: AppLocalizations.of(context)!.bankTransfer,
                      subtitle:
                          AppLocalizations.of(context)!.bankTransferSubtitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BankTransferScreen(
                                  bookingId: widget.bookingId,
                                  totalAmount: widget.totalAmount,
                                ),
                          ),
                        );
                      },
                      enabled: true,
                    ),
                    _buildPaymentMethod(
                      icon: Icons.qr_code,
                      title: AppLocalizations.of(context)!.eWallet,
                      subtitle: AppLocalizations.of(context)!.eWalletSubtitle,
                      enabled: false,
                    ),
                    const SizedBox(height: 32),
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
    bool enabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.orange[900]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: cardColor,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isDark
                  ? Colors.orange[200]
                  : const Color.fromARGB(255, 253, 109, 37),
        ),
        title: Text(
          title,
          style: TextStyle(color: !enabled ? Colors.grey : textColor),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: !enabled ? Colors.grey : textColor),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: enabled ? (onTap ?? _handlePayment) : null,
      ),
    );
  }
}
