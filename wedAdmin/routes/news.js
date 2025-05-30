const express = require('express');
const router = express.Router();
const newsController = require('../controllers/NewsController');
const upload = require('../middlewares/uploadImage');

router.get('/', newsController.index);
router.get('/create', newsController.create);
router.post('/store', upload.single('image'), newsController.store);

router.get('/edit/:id', newsController.edit);
router.post('/delete/:id', newsController.destroy);
router.post('/update/:id', upload.single('image'), newsController.update);

router.get('/view/:id', newsController.view);

module.exports = router;
