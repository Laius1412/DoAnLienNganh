import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dat_ve_xe/models/booking_model.dart';

class DetailMyTicket extends StatelessWidget {
  final Booking booking;

  const DetailMyTicket({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final travelDate = booking.getTravelDate();
    final seatNumbers = booking.seats.map((s) => s.seatPosition?.numberSeat ?? '').join(', ');
    final tripName = booking.seats.first.vehicle?.trip?.nameTrip ?? 'N/A';
    final plate = booking.seats.first.vehicle?.plate ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Chi tiết vé'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

                const Divider(),

                _buildDetailRow("Mã vé", booking.id),
                _buildDetailRow("Ngày đi", travelDate != null ? DateFormat('dd/MM/yyyy').format(travelDate) : 'Không rõ'),
                _buildDetailRow("Biển số xe", plate),
                _buildDetailRow("Ghế ngồi", seatNumbers),
                _buildDetailRow("Tổng tiền", "${NumberFormat("#,###", "vi_VN").format(booking.totalPrice)} đ"),
                _buildDetailRow("Điểm đi", booking.startLocationBooking),
                _buildDetailRow("Điểm đến", booking.endLocationBooking),

                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      const Text("Quét mã QR này tại cổng soát vé",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: booking.id,
                        version: QrVersions.auto,
                        size: 150.0,
                        backgroundColor: Colors.white,
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
            child: Text(title, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
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
}
