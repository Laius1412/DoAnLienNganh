import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dat_ve_xe/models/booking_model.dart';
import 'package:dat_ve_xe/server/user_service.dart';
import 'package:dat_ve_xe/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetailMyTicket extends StatefulWidget {
  final Booking booking;

  const DetailMyTicket({Key? key, required this.booking}) : super(key: key);

  @override
  State<DetailMyTicket> createState() => _DetailMyTicketState();
}

class _DetailMyTicketState extends State<DetailMyTicket> {
  String? userName;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = await UserService().getUserById(widget.booking.userId);
    setState(() {
      userName = user?.name ?? 'Không rõ';
      _loadingUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final booking = widget.booking;
    final travelDate = booking.getTravelDate();
    final seatNumbers = booking.seats.map((s) => s.seatPosition?.numberSeat ?? '').join(', ');
    final tripName = booking.seats.first.vehicle?.trip?.nameTrip ?? 'N/A';
    final plate = booking.seats.first.vehicle?.plate ?? 'N/A';
    final startTime = booking.seats.first.vehicle?.startTime ?? 'Không rõ';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(t.ticketDetail),
        backgroundColor: const Color(0xFFF36C21),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]?.withOpacity(0.95)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF36C21).withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.13 : 0.12),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    Chip(
                      label: Text(
                        _getStatusText(booking.statusBooking),
                        style: TextStyle(
                          color: _getStatusColor(booking.statusBooking),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getStatusColor(booking.statusBooking).withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: Theme.of(context).dividerColor),

                _buildDetailRow(t.ticketId, booking.id),
                _buildDetailRow(t.ticketUser, _loadingUser ? "Đang tải..." : (userName ?? "Không rõ")),
                _buildDetailRow(t.ticketDate, travelDate != null ? DateFormat('dd/MM/yyyy').format(travelDate) : 'Không rõ'),
                _buildDetailRow(t.ticketStartTime, startTime),
                _buildDetailRow(t.ticketPlate, plate),
                _buildDetailRow(t.ticketSeats, seatNumbers),
                _buildDetailRow(t.ticketTotal, "${NumberFormat("#,###", "vi_VN").format(booking.totalPrice)} đ"),
                _buildDetailRow(t.ticketStart, booking.startLocationBooking),
                _buildDetailRow(t.ticketEnd, booking.endLocationBooking),

                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(t.ticketQrGuide,
                          style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: QrImageView(
                          data: booking.id,
                          version: QrVersions.auto,
                          size: 170.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          ),
          const SizedBox(width: 12),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    final t = AppLocalizations.of(context)!;
    switch (status) {
      case 'pending':
        return t.pending;
      case 'pending_payment':
        return t.pendingPayment;
      case 'confirmed':
        return t.confirmed;
      case 'cancelled':
        return t.cancelled;
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
}
