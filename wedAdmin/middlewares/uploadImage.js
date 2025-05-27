const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../firebase/cloudinary');

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'news-images',
    allowed_formats: ['jpg', 'jpeg', 'png'],
  },
});

const upload = multer({ storage });

module.exports = upload;