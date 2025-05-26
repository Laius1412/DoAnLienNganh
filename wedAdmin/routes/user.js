const express = require('express');
const router = express.Router();
const userController = require('../controllers/UserController');


router.get('/', userController.index);


// Hiển thị form thêm
router.get('/create', (req, res) => {
  res.render('users/create', { layout: 'layout' });
});

// Xử lý POST thêm mới
router.post('/', userController.store);
// Xử lý Posy xóa người dùng 
router.post('/delete/:id' ,userController.destroy);
// xử lí edit tài khoản người dùng 
router.get('/edit/:id', userController.edit);
router.post('/:id', userController.update);

// xử lí xóa nhiều người 
router.post('/users/delete-multiple', userController.deleteMultiple);
// xử lí nút xuất file
router.get('/export-excel', userController.exportExcel);
module.exports = router;

