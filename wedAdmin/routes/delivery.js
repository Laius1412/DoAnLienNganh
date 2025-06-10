const express = require('express');
const router = express.Router();
const deliveryController = require('../controllers/DeliveryController');
const priceDeliveryController = require('../controllers/PriceDeliveryController');

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

module.exports = router;
