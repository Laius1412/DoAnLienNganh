const express = require('express');
const router = express.Router();
const deliveryController = require('../controllers/DeliveryController');

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

module.exports = router;
