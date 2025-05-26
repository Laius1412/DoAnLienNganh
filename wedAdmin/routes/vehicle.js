const express = require('express');
const router = express.Router();
const controller = require('../controllers/vehicleController');

router.get('/', controller.listVehicles);
router.get('/add', controller.renderAddForm);
router.post('/add', controller.addVehicle);
router.get('/edit/:id', controller.renderEditForm);
router.post('/edit/:id', controller.updateVehicle);
router.get('/delete/:id', controller.deleteVehicle);

module.exports = router;
