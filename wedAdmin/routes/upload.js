const express = require('express');
const router = express.Router();
const upload = require('../middlewares/uploadImage');

// Route upload ảnh cho CKEditor
router.post('/upload-image', upload.single('upload'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ uploaded: false, error: { message: 'Không có file nào được tải lên' } });
  }

  res.status(200).json({
    uploaded: true,
    url: req.file.path // Cloudinary trả về URL
  });
});

module.exports = router;
