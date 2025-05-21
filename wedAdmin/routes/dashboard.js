const express = require('express');
const router = express.Router();
const { isAuthenticated } = require('../middlewares/authMiddleware');

router.get('/', isAuthenticated, (req, res) => {
  res.render('dashboard', { user: req.session.user });
});

module.exports = router;
