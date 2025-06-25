import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/seat_position_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/vehicle_model.dart';
import 'dart:async';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _expiryCheckTimer;

  BookingService() {
    // Start periodic check for expired bookings
    _startExpiryCheck();
  }

  void _startExpiryCheck() {
    // Check every 30 seconds
    _expiryCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkAndCancelExpiredBookings();
      deleteCancelledBookings();
    });
  }

  void dispose() {
    _expiryCheckTimer?.cancel();
  }

  // Create a new booking with pending_payment status
  Future<String?> createBooking({
    required String userId,
    required String startLocationBooking,
    required String endLocationBooking,
    required int totalPrice,
    required List<Map<String, dynamic>> seatDetails,
    required DateTime selectedDate,
  }) async {
    try {
      final batch = _firestore.batch();
      final bookingRef = _firestore.collection('bookings').doc();
      final List<Map<String, dynamic>> seatsData = [];
      
      final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      // Check if seats are available
      for (var detail in seatDetails) {
        final numberSeat = detail['seatPosition']['numberSeat'] as String;
        final vehicle = detail['vehicle'] as Vehicle;
        
        final existingSeatQuery = await _firestore
            .collection('seatPositions')
            .where('numberSeat', isEqualTo: numberSeat)
            .where('vehicleId', isEqualTo: vehicle.id)
            .where('isBooked', isEqualTo: true)
            .where('date', isEqualTo: dateStr)
            .get();

        if (existingSeatQuery.docs.isNotEmpty) {
          throw Exception('Ghế $numberSeat đã được đặt cho ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}');
        }
      }

      // Create seat positions with temporary booking
      for (var detail in seatDetails) {
        final numberSeat = detail['seatPosition']['numberSeat'] as String;
        final vehicle = detail['vehicle'] as Vehicle;
        
        final seatRef = _firestore.collection('seatPositions').doc();
        
        final seatData = {
          'numberSeat': numberSeat,
          'isBooked': true,
          'date': dateStr,
          'vehicleId': vehicle.id,
          'bookingId': bookingRef.id,
          'status': 'pending_payment'
        };

        batch.set(seatRef, seatData);
        
        // Add seat data to booking
        seatsData.add({
          'seatPosition': {
            'id': seatRef.id,
            'numberSeat': numberSeat,
            'isBooked': true,
            'date': dateStr,
          },
          'vehicle': {
            'id': vehicle.id,
            'nameVehicle': vehicle.nameVehicle,
            'plate': vehicle.plate,
            'price': vehicle.price,
            'startTime': vehicle.startTime,
            'endTime': vehicle.endTime,
            if (vehicle.trip != null) 'trip': {
              'id': vehicle.trip!.id,
              'destination': vehicle.trip!.destination,
              'nameTrip': vehicle.trip!.nameTrip,
              'startLocation': vehicle.trip!.startLocation,
              'tripCode': vehicle.trip!.tripCode,
              'vRouter': vehicle.trip!.vRouter,
            },
            if (vehicle.vehicleType != null) 'vehicleType': {
              'id': vehicle.vehicleType!.id,
              'nameType': vehicle.vehicleType!.nameType,
              'seatCount': vehicle.vehicleType!.seatCount,
            },
          },
        });
      }

      // Create booking with pending_payment status and 5-minute deadline
      final now = DateTime.now();
      final paymentDeadline = now.add(const Duration(minutes: 5));

      final bookingData = {
        'id': bookingRef.id,
        'userId': userId,
        'createDate': now.toIso8601String(),
        'startLocationBooking': startLocationBooking,
        'endLocationBooking': endLocationBooking,
        'statusBooking': 'pending_payment',
        'totalPrice': totalPrice,
        'seats': seatsData,
        'paymentDeadline': paymentDeadline.toIso8601String(),
      };

      batch.set(bookingRef, bookingData);
      await batch.commit();

      print('Created new booking: ${bookingRef.id} with deadline: $paymentDeadline');
      return bookingRef.id;
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  // Timer to check payment status
  Future<void> _startPaymentTimer(String bookingId, DateTime deadline) async {
    await Future.delayed(Duration(seconds: 300)); // 5 minutes

    final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
    if (!bookingDoc.exists) return;

    final booking = Booking.fromMap(bookingId, bookingDoc.data() as Map<String, dynamic>);
    
    // If still in pending_payment status after 5 minutes, cancel the booking
    if (booking.statusBooking == 'pending_payment') {
      await cancelBooking(bookingId);
    }
  }

  // Cancel booking and release seats
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) return false;

      final data = bookingDoc.data() as Map<String, dynamic>;
      final batch = _firestore.batch();

      // Get all seats associated with this booking
      final seatsQuery = await _firestore
          .collection('seatPositions')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      // Release all seats
      for (var seatDoc in seatsQuery.docs) {
        batch.update(seatDoc.reference, {
          'isBooked': false,
          'bookingId': null,
          'status': 'available'
        });
      }

      // Update booking status to cancelled
      batch.update(_firestore.collection('bookings').doc(bookingId), {
        'statusBooking': 'cancelled',
        'paymentDeadline': null,
      });

      await batch.commit();
      print('Successfully cancelled booking: $bookingId');
      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  // Confirm payment and update booking status
  Future<bool> confirmPayment(String bookingId) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) return false;

      final booking = Booking.fromMap(bookingId, bookingDoc.data() as Map<String, dynamic>);
      
      // Only allow confirmation if in pending_payment status
      if (booking.statusBooking != 'pending_payment') {
        return false;
      }

      await _firestore.collection('bookings').doc(bookingId).update({
        'statusBooking': 'pending',
        'paymentDeadline': null,
      });

      return true;
    } catch (e) {
      print('Error confirming payment: $e');
      return false;
    }
  }

  // Lấy danh sách booking của user
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      print('Fetching bookings for user: $userId');
      
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${querySnapshot.docs.length} bookings in Firestore');

      final bookings = querySnapshot.docs.map((doc) {
        try {
          final data = doc.data();
          print('Processing booking ${doc.id} with data: $data');
          return Booking.fromMap(doc.id, data);
        } catch (e) {
          print('Error processing booking ${doc.id}: $e');
          return null;
        }
      }).where((booking) => booking != null).cast<Booking>().toList();

      // Sort bookings by createDate in memory
      bookings.sort((a, b) => b.createDate.compareTo(a.createDate));

      print('Successfully processed ${bookings.length} bookings');
      return bookings;
    } catch (e) {
      print('Error getting user bookings: $e');
      rethrow;
    }
  }

  // Lấy chi tiết booking theo ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final docSnapshot = await _firestore.collection('bookings').doc(bookingId).get();
      if (docSnapshot.exists) {
        return Booking.fromMap(docSnapshot.id, docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting booking: $e');
      return null;
    }
  }

  // Cập nhật trạng thái booking
  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) return false;

      final booking = Booking.fromMap(bookingDoc.id, bookingDoc.data() as Map<String, dynamic>);

      // Nếu hủy booking, cập nhật lại trạng thái ghế
      if (newStatus == 'cancelled') {
        for (var seat in booking.seats) {
          if (seat.seatPosition != null) {
            await _firestore.collection('seatPosition').doc(seat.seatPosition!.id).update({
              'isBooked': false,
            });
          }
        }
      }

      await _firestore.collection('bookings').doc(bookingId).update({
        'statusBooking': newStatus,
      });
      return true;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  // Tìm kiếm booking theo nhiều tiêu chí
  Future<List<Booking>> searchBookings({
    String? userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('bookings');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (status != null) {
        query = query.where('statusBooking', isEqualTo: status);
      }

      final querySnapshot = await query.get();
      var bookings = querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by date in memory if needed
      if (startDate != null) {
        bookings = bookings.where((booking) => 
          booking.createDate.isAfter(startDate) || 
          booking.createDate.isAtSameMomentAs(startDate)
        ).toList();
      }

      if (endDate != null) {
        bookings = bookings.where((booking) => 
          booking.createDate.isBefore(endDate) || 
          booking.createDate.isAtSameMomentAs(endDate)
        ).toList();
      }

      // Sort by createDate in memory
      bookings.sort((a, b) => b.createDate.compareTo(a.createDate));

      return bookings;
    } catch (e) {
      print('Error searching bookings: $e');
      return [];
    }
  }

  // Kiểm tra ghế đã được đặt chưa
  Future<bool> isSeatBooked(String seatPositionId) async {
    try {
      final seatDoc = await _firestore.collection('seatPosition').doc(seatPositionId).get();
      if (seatDoc.exists) {
        final data = seatDoc.data() as Map<String, dynamic>;
        return data['isBooked'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking seat status: $e');
      return false;
    }
  }

  // Lấy danh sách ghế của một xe
  Future<List<SeatPosition>> getSeatsForVehicle(String vehicleId) async {
    try {
      final querySnapshot = await _firestore
          .collection('seatPosition')
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('numberSeat')
          .get();

      return querySnapshot.docs
          .map((doc) => SeatPosition.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting seats: $e');
      return [];
    }
  }

  // Cập nhật trạng thái ghế
  Future<bool> updateSeatStatus(String seatId, String status) async {
    try {
      await _firestore.collection('seatPosition').doc(seatId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      print('Error updating seat status: $e');
      return false;
    }
  }

  // Cập nhật nhiều ghế cùng lúc
  Future<bool> updateMultipleSeatsStatus(List<String> seatIds, String status) async {
    try {
      final batch = _firestore.batch();
      
      for (var seatId in seatIds) {
        final seatRef = _firestore.collection('seatPosition').doc(seatId);
        batch.update(seatRef, {'status': status});
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error updating multiple seats: $e');
      return false;
    }
  }

  Future<List<Booking>> getBookingsForVehicle(String vehicleId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('bookings')
          .where('createDate', isGreaterThanOrEqualTo: startOfDay)
          .where('createDate', isLessThan: endOfDay)
          .get();

      final bookings = querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data()))
          .where((booking) => booking.seats.any((seat) => 
              seat.vehicle?.id == vehicleId))
          .toList();

      return bookings;
    } catch (e) {
      print('Error getting bookings for vehicle: $e');
      return [];
    }
  }

  // Cập nhật phương thức getBookedSeatsForVehicle
  Future<List<String>> getBookedSeatsForVehicle(String vehicleId, DateTime date) async {
    try {
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      
      final querySnapshot = await _firestore
          .collection('seatPositions')
          .where('vehicleId', isEqualTo: vehicleId)
          .where('isBooked', isEqualTo: true)
          .where('date', isEqualTo: dateStr)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['numberSeat'] as String)
          .toList();
    } catch (e) {
      print('Error getting booked seats: $e');
      return [];
    }
  }

  // Check and cancel expired bookings
  Future<void> checkAndCancelExpiredBookings() async {
    try {
      final now = DateTime.now();
      
      // Get all pending_payment bookings
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('statusBooking', isEqualTo: 'pending_payment')
          .get();

      print('Checking ${querySnapshot.docs.length} pending bookings for expiry');

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          if (data['paymentDeadline'] == null) continue;

          final paymentDeadline = DateTime.parse(data['paymentDeadline']);
          
          // Check if booking has expired
          if (paymentDeadline.isBefore(now)) {
            print('Found expired booking: ${doc.id}');
            await cancelBooking(doc.id);
          }
        } catch (e) {
          print('Error processing booking ${doc.id}: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error checking expired bookings: $e');
    }
  }

  // Xóa tất cả booking có trạng thái cancelled
  Future<void> deleteCancelledBookings() async {
    try {
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('statusBooking', isEqualTo: 'cancelled')
          .get();

      for (var doc in querySnapshot.docs) {
        await _firestore.collection('bookings').doc(doc.id).delete();
        print('Deleted cancelled booking: \'${doc.id}\'');
      }
    } catch (e) {
      print('Error deleting cancelled bookings: $e');
    }
  }
}
