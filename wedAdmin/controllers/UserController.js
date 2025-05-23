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

