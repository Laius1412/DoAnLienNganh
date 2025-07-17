const { db } = require("../firebase/config"); // Lấy đúng biến db đã export
const admin = require('firebase-admin');

exports.getAllBookings = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const tab = req.query.tab || 'pending';
    const phone = req.query.phone || '';
    const date = req.query.date || '';
    const time = req.query.time || '';
    const pageSize = 20;
    
    // Lấy tất cả bookings để lọc theo tab và tìm kiếm
    const bookingsSnapshot = await db.collection('bookings').get();
    let allBookings = [];
    
    for (const doc of bookingsSnapshot.docs) {
      const data = doc.data();
      let phoneNumber = '';
      if (data.userId) {
        const userDoc = await db.collection('users').doc(data.userId).get();
        if (userDoc.exists) {
          phoneNumber = userDoc.data().phone || '';
          // Chuyển +84... thành 0...
          if (phoneNumber.startsWith('+84')) {
            phoneNumber = '0' + phoneNumber.slice(3);
          }
        }
      }
      let dateValue = '';
      let startTime = '';
      if (Array.isArray(data.seats) && data.seats.length > 0) {
        const seat = data.seats[0];
        dateValue = seat.seatPosition?.date || '';
        startTime = seat.vehicle?.startTime || '';
      }
      allBookings.push({
        id: doc.id,
        phone: phoneNumber,
        date: dateValue,
        startTime,
        totalPrice: data.totalPrice,
        statusBooking: data.statusBooking,
        image: data.image || ''
      });
    }
    
    // Lọc theo tab
    let filteredBookings = allBookings;
    if (tab === 'pending') {
      filteredBookings = allBookings.filter(booking => booking.statusBooking === 'pending');
    } else if (tab === 'confirmed') {
      filteredBookings = allBookings.filter(booking => booking.statusBooking === 'confirmed');
    }
    
    // Đếm số lượng booking đang chờ phê duyệt
    const pendingCount = allBookings.filter(booking => booking.statusBooking === 'pending').length;

    // Lọc theo tìm kiếm
    if (phone) {
      filteredBookings = filteredBookings.filter(booking => 
        booking.phone.toLowerCase().includes(phone.toLowerCase())
      );
    }
    
    if (date) {
      filteredBookings = filteredBookings.filter(booking => 
        booking.date === date
      );
    }
    
    if (time) {
      filteredBookings = filteredBookings.filter(booking => 
        booking.startTime === time
      );
    }
    
    // Phân trang cho filtered bookings
    const startIndex = (page - 1) * pageSize;
    const endIndex = startIndex + pageSize;
    const bookings = filteredBookings.slice(startIndex, endIndex);
    const hasNextPage = endIndex < filteredBookings.length;
    
    res.render('bookings', { 
      bookings, 
      page, 
      hasNextPage, 
      tab,
      phone,
      date,
      time,
      pendingCount // truyền thêm biến này
    });
  } catch (error) {
    console.error('Error getting bookings:', error);
    res.render('bookings', { 
      bookings: [], 
      page: 1, 
      hasNextPage: false, 
      tab: 'pending',
      phone: '',
      date: '',
      time: '',
      pendingCount: 0 // fallback khi lỗi
    });
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
        dropOffPoint: data.endLocationBooking || '',
        image: data.image || ''
      }
    });
  } catch (error) {
    console.error('Error getting booking detail:', error);
    res.status(500).send('Lỗi lấy chi tiết booking');
  }
};

// Hàm gửi push notification FCM
async function sendPushNotificationToUser(userId, title, body, data = {}) {
  // Lấy fcmToken từ Firestore
  const userDoc = await db.collection('users').doc(userId).get();
  if (!userDoc.exists) return;
  const fcmToken = userDoc.data().fcmToken;
  if (!fcmToken) return;

  const message = {
    token: fcmToken,
    notification: {
      title: title,
      body: body,
    },
    data: data,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent FCM:', response);
  } catch (error) {
    console.error('Error sending FCM:', error);
  }
}

// Xác nhận đặt vé và gửi thông báo
exports.confirmBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;

    // 1. Update trạng thái booking
    await db.collection('bookings').doc(bookingId).update({ statusBooking: 'confirmed' });

    // 2. Lấy thông tin booking để lấy userId
    const bookingDoc = await db.collection('bookings').doc(bookingId).get();
    if (!bookingDoc.exists) {
      return res.status(404).send('Không tìm thấy booking');
    }
    const bookingData = bookingDoc.data();
    const userId = bookingData.userId;

    // 3. Ghi thông báo vào collection bookingNotice
    if (userId) {
      console.log('Chuẩn bị ghi thông báo cho user:', userId);
      await db.collection('bookingNotice').add({
        userId: userId,
        title: 'Vé đã được xác nhận',
        content: `Vé của bạn (ID: ${bookingId}) đã được xác nhận thành công!`,
        timestamp: new Date(),
        isRead: false,
        type: 'booking_confirmed',
        bookingId: bookingId,
      });
      console.log('Đã ghi xong thông báo bookingNotice');
      // Gửi push notification FCM
      await sendPushNotificationToUser(
        userId,
        'Vé đã được xác nhận',
        `Vé của bạn (ID: ${bookingId}) đã được xác nhận thành công!`,
        { bookingId }
      );
    }

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