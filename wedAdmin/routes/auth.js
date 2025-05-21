const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { isLoggedIn } = require('../middlewares/authMiddleware');

router.get('/login', isLoggedIn, authController.loginPage); // Sửa lại để sử dụng controller
router.post('/login', authController.loginUser);
router.get('/logout', authController.logoutUser); // Sử dụng controller thay vì viết trực tiếp

module.exports = router;