const express = require('express');
const router = express.Router();
const controller = require('../controllers/vehicleController');

router.get('/', controller.listVehicles);
router.post('/add', controller.addVehicle);
router.post('/edit/:id', controller.updateVehicle);
router.get('/delete/:id', controller.deleteVehicle);

module.exports = router;
