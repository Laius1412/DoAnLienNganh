const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();
const ExcelJS = require('exceljs');
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
// Xóa tài khoản
exports.destroy = async (req, res) => {
  const id = req.params.id;
  try {
    await db.collection('users').doc(id).delete();
    res.redirect('/user?deleted=1');
  } catch (error) {
    console.error(error);
    res.status(500).send('Lỗi khi xóa người dùng');
  }
};

// chỉnh sửa người dùng 
  exports.edit = async (req, res) => {
  const id = req.params.id;
  try {
    const doc = await db.collection('users').doc(id).get();
    if (!doc.exists) {
      return res.status(404).send('Người dùng không tồn tại');
    }

    const editUser = { id: doc.id, ...doc.data() };

    const snapshot = await db.collection('users').get();
    const users = [];
    snapshot.forEach(d => {
      users.push({ id: d.id, ...d.data() });
    });

    res.render('users/index', {
      users,
      query: '',
      editUser, 
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
// hàm xử lí xóa nhiều người 
exports.deleteMultiple = async (req, res) => {
  const ids = req.body.userIds;

  if (!ids || ids.length === 0) {
    return res.redirect('/user');
  }

  try {
    const deletePromises = ids.map(id => db.collection('users').doc(id).delete());
    await Promise.all(deletePromises);
    res.redirect('/user?deleted=1');
  } catch (error) {
    console.error('Lỗi khi xóa nhiều người dùng:', error);
    res.status(500).send('Lỗi khi xóa');
  }
};
// xử lí nút xuất file 
exports.exportExcel = async (req, res) => {
  try {
    const snapshot = await db.collection('users').get();
    const users = [];
    snapshot.forEach(doc => {
      users.push({ id: doc.id, ...doc.data() });
    });

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Users');

    worksheet.columns = [
      { header: 'Họ tên', key: 'name', width: 30 },
      { header: 'Email', key: 'email', width: 30 },
      { header: 'Giới tính', key: 'gender', width: 10 },
      { header: 'Ngày sinh', key: 'birth', width: 15 },
      { header: 'Số điện thoại', key: 'phone', width: 20 },
      { header: 'Vai trò', key: 'role', width: 15 },
    ];

    users.forEach(user => {
      worksheet.addRow({
        name: user.name,
        email: user.email,
        gender: user.gender === 'female' ? 'Nữ' : 'Nam',
        birth: user.birth ? new Date(user.birth).toLocaleDateString('vi-VN') : '',
        phone: user.phone,
        role: user.role,
      });
    });

    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    );
    res.setHeader(
      'Content-Disposition',
      'attachment; filename=' + 'users.xlsx'
    );

    await workbook.xlsx.write(res);
    res.end();

  } catch (error) {
    console.error('Lỗi khi xuất Excel:', error);
    res.status(500).send('Lỗi khi xuất file Excel');
  }
};


