const express = require('express');
const router = express.Router();
const userController = require('../controllers/UserController');


router.get('/', userController.index);

module.exports = router;
// Hiển thị form thêm
router.get('/create', (req, res) => {
  res.render('users/create', { layout: 'layout' });
});

// Xử lý POST thêm mới
router.post('/', userController.store);
