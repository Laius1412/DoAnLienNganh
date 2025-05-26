const express = require("express");
const router = express.Router();
const tripController = require("../controllers/tripController");

router.get("/", tripController.getTrips);
router.post("/add", tripController.addTrip);
router.post("/edit/:id", tripController.updateTrip);
router.post("/delete/:id", tripController.deleteTrip);
router.post("/delete-multiple", tripController.deleteMultipleTrips);

module.exports = router;
