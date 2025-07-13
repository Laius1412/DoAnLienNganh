const express = require('express');
const router = express.Router();
const deliveryController = require('../controllers/DeliveryController');
const priceDeliveryController = require('../controllers/PriceDeliveryController');
const DeliveryController = require('../controllers/DeliveryController');

console.log('deliveryController:', deliveryController);
console.log('priceDeliveryController:', priceDeliveryController);

router.get('/', deliveryController.index);
router.get('/regions', deliveryController.getRegions);
router.post('/regions', deliveryController.addRegion);
router.put('/regions/:id', deliveryController.updateRegion);
router.delete('/regions/:id', deliveryController.deleteRegion);

router.post('/office', deliveryController.addOffice);
router.put('/office/:id', deliveryController.updateOffice);
router.delete('/office/:id', deliveryController.deleteOffice);

router.get('/offices/:regionId', deliveryController.getOfficesByRegion);
router.get('/office/:id', deliveryController.getOfficeById);

// Price Delivery Routes
router.get('/price_delivery', priceDeliveryController.getPriceDeliveryPage);
router.get('/price_delivery/regions', priceDeliveryController.getRegions);
router.get('/price_delivery/list', priceDeliveryController.getPriceDeliveryList);
router.post('/price_delivery', priceDeliveryController.createPriceDelivery);
router.put('/price_delivery/:id', priceDeliveryController.updatePriceDelivery);
router.delete('/price_delivery', priceDeliveryController.deletePriceDeliveries);

// Order route

router.get('/order_manage', DeliveryController.orderManagePage)
// API lấy danh sách đơn hàng
router.get('/api/delivery-orders', deliveryController.getDeliveryOrders);
// API cập nhật đơn hàng
router.put('/api/delivery-orders/:id', deliveryController.updateDeliveryOrder);
// API lấy danh sách offices
router.get('/api/offices', deliveryController.getOffices);
// API lấy danh sách regions
router.get('/api/regions', deliveryController.getRegions);
// API lấy danh sách users
router.get('/api/users', deliveryController.getUsers);

// Test FCM notification endpoint
router.post('/api/test-fcm', deliveryController.testFCMNotification);

module.exports = router;
