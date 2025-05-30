import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/seat_position_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/vehicle_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo booking mới
  Future<String?> createBooking({
    required String userId,
    required String startLocationBooking,
    required String endLocationBooking,
    required int totalPrice,
    required List<Map<String, dynamic>> seatDetails,
    required DateTime selectedDate,
  }) async {
    try {
      print('Starting booking process...');
      print('User ID: $userId');
      print('Selected seats: ${seatDetails.length}');

      final batch = _firestore.batch();
      final bookingRef = _firestore.collection('bookings').doc();
      final List<BookingSeat> seats = [];
      
      // Format date as YYYY-MM-DD
      final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      // Kiểm tra xem có ghế nào đã được đặt chưa
      for (var detail in seatDetails) {
        final numberSeat = detail['seatPosition']['numberSeat'] as String;
        final vehicle = detail['vehicle'] as Vehicle;
        
        print('Checking seat $numberSeat for vehicle ${vehicle.id}...');
        
        final existingSeatQuery = await _firestore
            .collection('seatPositions')
            .where('numberSeat', isEqualTo: numberSeat)
            .where('vehicleId', isEqualTo: vehicle.id)
            .where('isBooked', isEqualTo: true)
            .where('date', isEqualTo: dateStr)
            .get();

        if (existingSeatQuery.docs.isNotEmpty) {
          print('Seat $numberSeat is already booked for date $dateStr');
          throw Exception('Ghế $numberSeat đã được đặt cho ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}');
        }
      }

      print('All seats are available, proceeding with booking...');

      // Tạo và cập nhật thông tin ghế
      for (var detail in seatDetails) {
        final numberSeat = detail['seatPosition']['numberSeat'] as String;
        final vehicle = detail['vehicle'] as Vehicle;
        
        print('Creating seat position for seat $numberSeat...');
        
        final seatRef = _firestore.collection('seatPositions').doc();
        
        final seatPosition = SeatPosition(
          id: seatRef.id,
          numberSeat: numberSeat,
          isBooked: true,
          date: dateStr,
        );

        final seatData = {
          ...seatPosition.toMap(),
          'vehicleId': vehicle.id,
        };

        print('Adding seat data to batch: $seatData');
        batch.set(seatRef, seatData);
        seats.add(BookingSeat(seatPosition: seatPosition, vehicle: vehicle));
      }

      final booking = Booking(
        id: bookingRef.id,
        userId: userId,
        createDate: DateTime.now(),
        startLocationBooking: startLocationBooking,
        endLocationBooking: endLocationBooking,
        statusBooking: 'pending',
        totalPrice: totalPrice,
        seats: seats,
      );

      print('Creating booking with ID: ${bookingRef.id}');
      print('Booking data: ${booking.toMap()}');

      batch.set(bookingRef, booking.toMap());
      
      print('Committing batch...');
      await batch.commit();
      print('Batch committed successfully');
      
      return bookingRef.id;
    } catch (e, stackTrace) {
      print('Error creating booking:');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Lấy danh sách booking của user
  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user bookings: $e');
      return [];
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

      if (startDate != null) {
        query = query.where('createDate', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createDate', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
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
}
