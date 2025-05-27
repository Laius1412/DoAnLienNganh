const express = require('express');
const router = express.Router();
const newsController = require('../controllers/NewsController');
const upload = require('../middlewares/uploadImage');

router.get('/', newsController.index);
router.get('/create', newsController.create);
router.post('/store', upload.single('image'), newsController.store);

module.exports = router;
