const { db } = require("../firebase/config"); // Lấy đúng biến db đã export

exports.getAllBookings = async (req, res) => {
  try {
    const bookingsSnapshot = await db.collection('bookings').get();
    const bookings = [];

    for (const doc of bookingsSnapshot.docs) {
      const data = doc.data();
      let phone = '';

      if (data.userId) {
        const userDoc = await db.collection('users').doc(data.userId).get();
        if (userDoc.exists) {
          phone = userDoc.data().phone || '';
        }
      }

      let date = '';
      let startTime = '';
      if (Array.isArray(data.seats) && data.seats.length > 0) {
        const seat = data.seats[0];
        date = seat.seatPosition?.date || '';
        startTime = seat.vehicle?.startTime || '';
      }

      bookings.push({
        id: doc.id,
        phone,
        date,
        startTime,
        totalPrice: data.totalPrice,
        statusBooking: data.statusBooking
      });
    }

    res.render('bookings', { bookings });
  } catch (error) {
    console.error('Error getting bookings:', error);
    res.status(500).send('Lỗi lấy dữ liệu booking');
  }
};


// Lấy chi tiết booking
exports.getBookingDetail = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const doc = await db.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return res.status(404).send('Không tìm thấy booking');
    const data = doc.data();
    let user = {};
    if (data.userId) {
      const userDoc = await db.collection('users').doc(data.userId).get();
      if (userDoc.exists) {
        user = userDoc.data();
      }
    }
    // Lấy thông tin seats[0]
    let seatPosition = {};
    let vehicle = {};
    let trip = {};
    let vehicleType = {};
    let startTime = '';
    let endTime = '';
    if (Array.isArray(data.seats) && data.seats.length > 0) {
      seatPosition = data.seats[0].seatPosition || {};
      vehicle = data.seats[0].vehicle || {};
      trip = vehicle.trip || {};
      vehicleType = vehicle.vehicleType || {};
      startTime = vehicle.startTime || '';
      endTime = vehicle.endTime || '';
    }
    res.render('bookingDetail', {
      booking: {
        id: doc.id,
        ...data,
        user,
        seatPosition,
        vehicle,
        trip,
        vehicleType,
        startTime,
        endTime,
        pickUpPoint: data.startLocationBooking || '',
        dropOffPoint: data.endLocationBooking || ''
      }
    });
  } catch (error) {
    console.error('Error getting booking detail:', error);
    res.status(500).send('Lỗi lấy chi tiết booking');
  }
};

// Xác nhận đặt vé
exports.confirmBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    await db.collection('bookings').doc(bookingId).update({ statusBooking: 'confirmed' });
    res.redirect('/bookings/' + bookingId);
  } catch (error) {
    console.error('Error confirming booking:', error);
    res.status(500).send('Lỗi xác nhận booking');
  }
};

// Hủy vé
exports.cancelBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    await db.collection('bookings').doc(bookingId).update({ statusBooking: 'cancelled' });
    res.redirect('/bookings/' + bookingId);
  } catch (error) {
    console.error('Error cancelling booking:', error);
    res.status(500).send('Lỗi hủy booking');
  }
}; 