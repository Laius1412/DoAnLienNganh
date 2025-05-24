const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();

exports.index = async (req, res) => {
  try {
    const query = (req.query.q || '').toLowerCase(); // từ khóa tìm kiếm
    const snapshot = await db.collection('users').get();

    const users = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      const name = (data.name || '').toLowerCase();
      const phone = (data.phone || '').toLowerCase();

      // Lọc theo tên hoặc số điện thoại nếu có query
      if (!query || name.includes(query) || phone.includes(query)) {
        users.push({ id: doc.id, ...data });
      }
    });

    res.render('users/index', {
      users,
      query: req.query.q || '',
      layout: 'layout'
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Lỗi khi lấy danh sách người dùng');
  }
};
// thêm tài khoản mới
exports.store = async (req, res) => {
  const { name, email, gender, birth, phone, role } = req.body;

  try {
    await db.collection('users').add({
      name,
      email,
      gender,
      birth,
      phone,
      role
    });

    res.redirect('/user'); // Trở về danh sách
  } catch (error) {
    console.error(error);
    res.status(500).send('Lỗi khi thêm người dùng');
  }
};
// xóa tài khoản
exports.destroy = async (req, res) => {
  const id = req.params.id;
  try {
    await db.collection('users').doc(id).delete();
    res.redirect('/user');
  }catch (error) {
    console.error(error);
    res.status(500).send('Lỗi khi xóa người dùng');
  }
}
// chỉnh sửa người dùng 
  exports.edit = async (req, res) => {
  const id = req.params.id;
  try {
    const doc = await db.collection('users').doc(id).get();
    if (!doc.exists) {
      return res.status(404).send('Người dùng không tồn tại');
    }

    const user = { id: doc.id, ...doc.data() };

    const snapshot = await db.collection('users').get();
    const users = [];
    snapshot.forEach(d => {
      users.push({ id: d.id, ...d.data() });
    });

   res.render('users/edit', {
  user,  // chỉ cần 1 user để sửa
  layout: 'layout'
});
  } catch (error) {
    console.error(error);
    res.status(500).send('Lỗi khi lấy thông tin người dùng');
  }
};

exports.update = async (req, res) => {
  const id = req.params.id;
  const { name, email, phone, gender, birth, role } = req.body;
  try {
    await db.collection('users').doc(id).update({
      name, email, phone, gender, birth, role
    });
    res.redirect('/user');
  } catch (error) {
    console.error(error);
    res.status(500).send('Lỗi khi cập nhật người dùng');
  }
};


