const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();
const ExcelJS = require('exceljs');
const admin = require('firebase-admin');
const auth = admin.auth();

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
  const { name, email, gender, birth, phone, role, password } = req.body;
  const cleanedPhone = phone.trim().replace(/\s+/g, '');

  try {
    // Kiểm tra trùng số điện thoại
    const snapshot = await db.collection('users')
      .where('phone', '==', cleanedPhone)
      .get();

    if (!snapshot.empty) {
      const usersSnapshot = await db.collection('users').get();
      const users = [];
      usersSnapshot.forEach(doc => users.push({ id: doc.id, ...doc.data() }));

      return res.render('users/index', {
        users,
        query: '',
        layout: 'layout',
        error: 'Số điện thoại đã tồn tại, vui lòng nhập số khác!'
      });
    }

    // Tạo người dùng trong Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
      phoneNumber: `+84${cleanedPhone.slice(1)}` // đảm bảo định dạng sđt quốc tế nếu cần
    });

    // Lưu thông tin người dùng vào Firestore kèm uid
    await db.collection('users').doc(userRecord.uid).set({
      name,
      email,
      gender,
      birth,
      phone: cleanedPhone,
      role,
      uid: userRecord.uid
    });

    res.redirect('/user');
  } catch (error) {
    console.error(error);

    // Nếu lỗi là email đã được sử dụng
    if (error.code === 'auth/email-already-exists') {
      const usersSnapshot = await db.collection('users').get();
      const users = [];
      usersSnapshot.forEach(doc => users.push({ id: doc.id, ...doc.data() }));

      return res.render('users/index', {
        users,
        query: '',
        layout: 'layout',
        error: 'Email đã tồn tại trong hệ thống!'
      });
    }

    res.status(500).send('Lỗi khi thêm người dùng');
  }
};



// Xóa tài khoản
exports.destroy = async (req, res) => {
  const id = req.params.id;

  try {
    // Xóa khỏi Authentication
    await admin.auth().deleteUser(id);

    // Xóa khỏi Firestore
    await db.collection('users').doc(id).delete();

    res.redirect('/user?deleted=1');
  } catch (error) {
    console.error('Lỗi khi xóa người dùng:', error);
    res.status(500).send('Lỗi khi xóa người dùng');
  }
};


// Chỉnh sửa người dùng
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

// Cập nhật người dùng
exports.update = async (req, res) => {
  const docId = req.params.id;
  const { name, email, phone, gender, birth, role } = req.body;

  try {
    const docRef = db.collection('users').doc(docId);
    const docSnap = await docRef.get();

    if (!docSnap.exists) {
      return res.status(404).send('Người dùng không tồn tại');
    }

    const userData = docSnap.data();
    const uid = userData.uid;

    if (!uid) {
      return res.status(400).send('Không tìm thấy UID để cập nhật người dùng');
    }

    const cleanedPhone = phone.trim().replace(/\s+/g, '');
    const formattedPhone = cleanedPhone.startsWith('0')
      ? `+84${cleanedPhone.slice(1)}`
      : cleanedPhone;

    // Cập nhật Auth trước
    await auth.updateUser(uid, {
      displayName: name,
      email: email,
      phoneNumber: formattedPhone
    });

    // Sau đó mới cập nhật Firestore
    await docRef.update({
      name,
      email,
      phone: cleanedPhone,
      gender,
      birth,
      role
    });

    res.redirect('/user');
  } catch (error) {
    console.error('Lỗi khi cập nhật người dùng:', error);

    let message = 'Lỗi khi cập nhật người dùng';
    if (error.code === 'auth/email-already-exists') {
      message = 'Email đã tồn tại!';
    } else if (error.code === 'auth/phone-number-already-exists') {
      message = 'Số điện thoại đã tồn tại!';
    }

    res.status(500).send(message);
  }
};


  

  


// Xóa nhiều người dùng
exports.deleteMultiple = async (req, res) => {
  const ids = req.body.userIds;

  if (!ids || ids.length === 0) {
    return res.redirect('/user');
  }

  try {
    const deletePromises = ids.map(async (id) => {
      await admin.auth().deleteUser(id); // Xóa trên Authentication
      await db.collection('users').doc(id).delete(); // Xóa trên Firestore
    });

    await Promise.all(deletePromises);
    res.redirect('/user?deleted=1');
  } catch (error) {
    console.error('Lỗi khi xóa nhiều người dùng:', error);
    res.status(500).send('Lỗi khi xóa');
  }
};


// Xuất danh sách người dùng ra file Excel
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
      'attachment; filename=users.xlsx'
    );

    await workbook.xlsx.write(res);
    res.end();

  } catch (error) {
    console.error('Lỗi khi xuất Excel:', error);
    res.status(500).send('Lỗi khi xuất file Excel');
  }
};
