const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();
const upload = require('../middlewares/uploadImage');

// Hiển thị danh sách bài viết
exports.index = async (req, res) => {
  const snapshot = await db.collection('news').orderBy('createAt', 'desc').get();
  const news = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  res.render('news/index', { news });
};

// Giao diện tạo bài viết
exports.create = (req, res) => {
  res.render('news/create');
};

// Lưu bài viết mới
exports.store = async (req, res) => {
  try {
    const { titles, contents } = req.body;
    let imageUrl = null;

    if (!titles || !contents) {
      return res.status(400).send('Tiêu đề và nội dung là bắt buộc.');
    }

    // Xử lý upload ảnh nếu có
    if (req.file) {
      imageUrl = req.file.path;
    }

    await db.collection('news').add({
      titles,
      contents,
      Img: imageUrl,
      createAt: new Date()
    });

    res.redirect('/news');
  } catch (error) {
    console.error('Lỗi khi thêm bài viết:', error);
    res.status(500).send('Đã xảy ra lỗi khi thêm bài viết.');
  }
};

// Giao diện chỉnh sửa bài viết
exports.edit = async (req, res) => {
  try {
    const id = req.params.id;
    const doc = await db.collection('news').doc(id).get();

    if (!doc.exists) {
      return res.status(404).send('Không tìm thấy bài viết');
    }

    res.render('news/edit', {
      newsItem: { id: doc.id, ...doc.data() }
    });
  } catch (error) {
    console.error('Lỗi khi lấy thông tin bài viết:', error);
    res.status(500).send('Có lỗi khi lấy thông tin bài viết');
  }
};

// Cập nhật bài viết
exports.update = async (req, res) => {
  try {
    const id = req.params.id;
    const { titles, contents } = req.body;

    if (!titles || !contents) {
      return res.status(400).send('Tiêu đề và nội dung là bắt buộc.');
    }

    const dataUpdate = { 
      titles, 
      contents,
      updateAt: new Date()
    };

    // Xử lý upload ảnh mới nếu có
    if (req.file) {
      dataUpdate.Img = req.file.path;
    }

    await db.collection('news').doc(id).update(dataUpdate);

    res.redirect('/news');
  } catch (error) {
    console.error('Lỗi khi cập nhật bài viết:', error);
    res.status(500).send('Có lỗi khi cập nhật bài viết');
  }
};

// Xóa bài viết
exports.destroy = async (req, res) => {
  try {
    const id = req.params.id;
    await db.collection('news').doc(id).delete();
    res.redirect('/news');
  } catch (error) {
    console.error('Lỗi khi xóa bài viết:', error);
    res.status(500).send('Có lỗi khi xóa bài viết');
  }
};

// Xem chi tiết bài viết
exports.view = async (req, res) => {
  try {
    const id = req.params.id;
    const doc = await db.collection('news').doc(id).get();
    if (!doc.exists) return res.status(404).send('Không tìm thấy bài viết');
    const data = doc.data();
    res.render('news/view', { newsItem: { id, ...data } });
  } catch (error) {
    console.error('Lỗi khi xem bài viết:', error);
    res.status(500).send('Có lỗi khi xem bài viết');
  }
};
