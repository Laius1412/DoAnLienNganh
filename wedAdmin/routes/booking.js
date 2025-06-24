const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');

// Trang quản lý vé đã đặt
router.get('/', bookingController.getAllBookings);

// Xem chi tiết booking
router.get('/:id', bookingController.getBookingDetail);

// Xác nhận đặt vé
router.post('/:id/confirm', bookingController.confirmBooking);

// Hủy vé
router.post('/:id/cancel', bookingController.cancelBooking);

module.exports = router; 