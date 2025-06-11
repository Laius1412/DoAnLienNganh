
const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();

exports.index = async (req, res) => {
  const snapshot = await db.collection('news').orderBy('createAt', 'desc').get();
  const news = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  res.render('news/index', { news });
};

exports.create = (req, res) => {
  res.render('news/create');
};

exports.store = async (req, res) => {
  try {
    const { titles, contents } = req.body;
    const Img = req.file?.path || ''; // path là Cloudinary URL khi dùng CloudinaryStorage

    // Nếu cần chắc chắn hơn, bạn có thể log ra để kiểm tra:
    // console.log('File upload:', req.file);

    if (!titles || !contents) {
      return res.status(400).send('Tiêu đề và nội dung là bắt buộc.');
    }

    await db.collection('news').add({
      titles,
      contents,
      Img,
      createAt: new Date()
    });

    res.redirect('/news');
  } catch (error) {
    console.error('Lỗi khi thêm bài viết:', error);
    res.status(500).send('Đã xảy ra lỗi khi thêm bài viết.');
  }
};


// chỉnh sửa
exports.edit = async (req, res) => {
  const id = req.params.id;
  const doc = await db.collection('news').doc(id).get();

  if (!doc.exists) {
    return res.status(404).send('Không tìm thấy bài viết');
  }

  res.render('news/edit', {
    newsItem: { id: doc.id,...doc.data()}
  });
};
// update
exports.update = async (req, res) => {
  const id = req.params.id;
  const {titles,contents} = req.body;
  const Img = req.file?.path || null;


  const dataUpdate = {titles,contents};
  if(Img) dataUpdate.Img = Img;

  await db.collection('news').doc(id).update(dataUpdate);
  res.redirect('/news');
}
// xoa bai viet
exports.destroy = async (req, res) => {
  const id = req.params.id;
  await db.collection('news').doc(id).delete();
  res.redirect('/news');
};

// xem chi tiết bài viết 
exports.view = async (req, res) => {
  const id = req.params.id;
  const doc = await db.collection('news').doc(id).get();
  if (!doc.exists) return res.status(404).send('Không tìm thấy bài viết');
  const data = doc.data();
  res.render('news/view', { newsItem: { id, ...data } });
};