const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();
const ExcelJS = require('exceljs');
const admin = require('firebase-admin');
const auth = admin.auth();

// Danh sách người dùng + tìm kiếm
const index = async (req, res) => {
  try {
    const query = (req.query.q || '').toLowerCase();
    const sort = req.query.sort || '';
    const snapshot = await db.collection('users').get();
    const users = [];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const name = (data.name || '').toLowerCase();
      const phone = (data.phone || '').toLowerCase();

      if (!query || name.includes(query) || phone.includes(query)) {
        // Đếm số lần đặt vé của user này
        const bookingSnap = await db.collection('bookings').where('userId', '==', doc.id).get();
        const bookingCount = bookingSnap.size;
        users.push({ id: doc.id, ...data, bookingCount });
      }
    }

    // Sắp xếp theo yêu cầu
    if (sort === 'name-asc') {
      // Sắp xếp theo tên (từ cuối cùng trong họ tên)
      users.sort((a, b) => {
        const getLastName = (fullName) => {
          if (!fullName) return '';
          const parts = fullName.trim().split(' ');
          return parts[parts.length - 1].toLowerCase();
        };
        return getLastName(a.name).localeCompare(getLastName(b.name), 'vi', { sensitivity: 'base' });
      });
    } else if (sort === 'booking-desc') {
      users.sort((a, b) => (b.bookingCount || 0) - (a.bookingCount || 0));
    }

    res.render('users/index', {
      users,
      query: req.query.q || '',
      layout: 'layout',
      updated: req.query.updated,
      added: req.query.added
    });
  } catch (error) {
    console.error(error);
    res.status(500).send('Lỗi khi lấy danh sách người dùng');
  }
};

// Thêm người dùng
const store = async (req, res) => {
  const { name, email, gender, birth, phone, role, password } = req.body;

  if (!email || !password || !name || !phone) {
    return res.status(400).send('Vui lòng điền đầy đủ thông tin bắt buộc.');
  }

  let formattedPhone = phone;
  if (phone.startsWith('0')) {
    formattedPhone = '+84' + phone.slice(1);
  }

  try {
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: name,
      phoneNumber: formattedPhone,
    });

    await db.collection('users').doc(userRecord.uid).set({
      name,
      email,
      gender: gender || null,
      birth: birth || null,
      phone: formattedPhone,
      role: role || 'user',
      uid: userRecord.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.redirect('/user?added=1');
  } catch (error) {
    console.error('Chi tiết lỗi khi thêm người dùng:', error);

    if (error.code === 'auth/email-already-exists') {
      return res.status(400).send('Email đã tồn tại.');
    }
    if (error.code === 'auth/invalid-email') {
      return res.status(400).send('Email không hợp lệ.');
    }
    if (error.code === 'auth/invalid-password') {
      return res.status(400).send('Mật khẩu phải có ít nhất 6 ký tự.');
    }
    if (error.code === 'auth/phone-number-already-exists') {
      return res.status(400).send('Số điện thoại đã được sử dụng.');
    }
    if (error.code === 'auth/invalid-phone-number') {
      return res.status(400).send('Số điện thoại không hợp lệ.');
    }

    res.status(500).send('Lỗi khi thêm người dùng: ' + error.message);
  }
};

// Xóa 1 người dùng
const destroy = async (req, res) => {
  const id = req.params.id;
  try {
    await auth.deleteUser(id);
    await db.collection('users').doc(id).delete();
    res.redirect('/user?deleted=1');
  } catch (error) {
    console.error('Lỗi khi xóa người dùng:', error);
    res.status(500).send('Lỗi khi xóa người dùng');
  }
};

// Hiển thị form sửa người dùng
const edit = async (req, res) => {
  const id = req.params.id;
  try {
    const doc = await db.collection('users').doc(id).get();
    if (!doc.exists) {
      return res.status(404).send('Người dùng không tồn tại');
    }

    const editUser = { id: doc.id, ...doc.data() };
    const snapshot = await db.collection('users').get();
    const users = [];
    snapshot.forEach(d => users.push({ id: d.id, ...d.data() }));

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
const update = async (req, res) => {
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

    const cleanedPhone = phone.trim().replace(/\s+/g, '');
    const formattedPhone = cleanedPhone.startsWith('0') ? `+84${cleanedPhone.slice(1)}` : cleanedPhone;

    // Nếu có UID thì cập nhật Firebase Authentication
    if (uid) {
      await auth.updateUser(uid, {
        displayName: name,
        email: email,
        phoneNumber: formattedPhone,
      });
    } else {
      console.warn(`⚠ Người dùng ${docId} không có UID, chỉ cập nhật Firestore`);
    }

    // Cập nhật Firestore
    await docRef.update({
      name,
      email,
      phone: formattedPhone,
      gender,
      birth,
      role,
    });

    res.redirect('/user?updated=1');
  } catch (error) {
    console.error('Lỗi khi cập nhật người dùng:', error);
    let message = 'Lỗi khi cập nhật người dùng';
    if (error.code === 'auth/email-already-exists') message = 'Email đã tồn tại!';
    else if (error.code === 'auth/phone-number-already-exists') message = 'Số điện thoại đã tồn tại!';
    res.status(500).send(message);
  }
};

// Xóa nhiều người dùng
const deleteMultiple = async (req, res) => {
  const ids = req.body.userIds;
  if (!ids || ids.length === 0) return res.redirect('/user');

  try {
    const deletePromises = ids.map(async (id) => {
      await auth.deleteUser(id);
      await db.collection('users').doc(id).delete();
    });

    await Promise.all(deletePromises);
    res.redirect('/user?deleted=1');
  } catch (error) {
    console.error('Lỗi khi xóa nhiều người dùng:', error);
    res.status(500).send('Lỗi khi xóa');
  }
};

// Xuất file Excel
const exportExcel = async (req, res) => {
  try {
    const snapshot = await db.collection('users').get();
    const users = [];
    for (const doc of snapshot.docs) {
      const data = doc.data();
      // Đếm số lần đặt vé của user này
      const bookingSnap = await db.collection('bookings').where('userId', '==', doc.id).get();
      const bookingCount = bookingSnap.size;
      users.push({ id: doc.id, ...data, bookingCount });
    }

    // Sắp xếp theo yêu cầu
    const sort = req.query.sort;
    if (sort === 'name-asc') {
      users.sort((a, b) => {
        const getLastName = (fullName) => {
          if (!fullName) return '';
          const parts = fullName.trim().split(' ');
          return parts[parts.length - 1].toLowerCase();
        };
        return getLastName(a.name).localeCompare(getLastName(b.name), 'vi', { sensitivity: 'base' });
      });
    } else if (sort === 'booking-desc') {
      users.sort((a, b) => (b.bookingCount || 0) - (a.bookingCount || 0));
    }

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Users');

    worksheet.columns = [
      { header: 'Họ tên', key: 'name', width: 30 },
      { header: 'Email', key: 'email', width: 30 },
      { header: 'Giới tính', key: 'gender', width: 10 },
      { header: 'Ngày sinh', key: 'birth', width: 15 },
      { header: 'Số điện thoại', key: 'phone', width: 20 },
      { header: 'Số vé', key: 'bookingCount', width: 10 },
      { header: 'Vai trò', key: 'role', width: 15 },
    ];

    users.forEach(user => {
      worksheet.addRow({
        name: user.name,
        email: user.email,
        gender: user.gender === 'female' ? 'Nữ' : 'Nam',
        birth: user.birth ? new Date(user.birth).toLocaleDateString('vi-VN') : '',
        phone: user.phone,
        bookingCount: user.bookingCount || 0,
        role: user.role,
      });
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=users.xlsx');

    await workbook.xlsx.write(res);
    res.end();
  } catch (error) {
    console.error('Lỗi khi xuất Excel:', error);
    res.status(500).send('Lỗi khi xuất file Excel');
  }
};
// Đồng bộ thêm field uid cho các user thiếu
const syncUidField = async (req, res) => {
  try {
    const snapshot = await db.collection('users').get();
    let updated = 0;

    const batch = db.batch();

    snapshot.forEach(doc => {
      const data = doc.data();
      if (!data.uid) {
        const docRef = db.collection('users').doc(doc.id);
        batch.update(docRef, { uid: doc.id });
        updated++;
      }
    });

    await batch.commit();

    res.send(`✅ Đã cập nhật ${updated} người dùng bị thiếu UID.`);
  } catch (error) {
    console.error('Lỗi khi đồng bộ UID:', error);
    res.status(500).send('Lỗi khi đồng bộ UID');
  }
};

// ✅ Export đầy đủ, đúng cách
module.exports = {
  index,
  store,
  destroy,
  edit,
  update,
  deleteMultiple,
  exportExcel,
  syncUidField
};
