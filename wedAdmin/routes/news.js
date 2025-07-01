const express = require('express');
const router = express.Router();
const newsController = require('../controllers/NewsController');
const upload = require('../middlewares/uploadImage');

// Danh sách bài viết
router.get('/', newsController.index);

// Giao diện tạo bài viết
router.get('/create', newsController.create);

// Lưu bài viết mới (có upload file)
router.post('/store', upload.single('image'), newsController.store);

// Giao diện chỉnh sửa
router.get('/edit/:id', newsController.edit);

// Cập nhật bài viết (có upload file)
router.post('/update/:id', upload.single('image'), newsController.update);

// Xóa bài viết
router.post('/delete/:id', newsController.destroy);

// Xem chi tiết bài viết
router.get('/view/:id', newsController.view);

module.exports = router;
