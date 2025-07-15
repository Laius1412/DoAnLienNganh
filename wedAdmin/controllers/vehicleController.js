const { db } = require("../firebase/config");

const vehicleCollection = db.collection('vehicle');
const vehicleTypeCollection = db.collection('vehicleType');
const tripCollection = db.collection('trip');

// GET /vehicles
exports.listVehicles = async (req, res) => {
  try {
    const { vehicleTypeId, tripId } = req.query;
    const snapshot = await vehicleCollection.get();
    let vehicles = [];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      // Kiểm tra ID trước khi gọi doc()
      const [typeDoc, tripDoc] = await Promise.all([
        data.vehicleTypeId ? vehicleTypeCollection.doc(data.vehicleTypeId).get() : null,
        data.tripId ? tripCollection.doc(data.tripId).get() : null
      ]);
      vehicles.push({
        id: doc.id,
        ...data,
        vehicleTypeName: typeDoc?.exists ? typeDoc.data().nameType : 'Không rõ',
        tripName: tripDoc?.exists ? tripDoc.data().nameTrip : 'Không rõ'
      });
    }

    // Lọc theo loại xe nếu có
    if (vehicleTypeId) {
      vehicles = vehicles.filter(v => v.vehicleTypeId === vehicleTypeId);
    }
    // Lọc theo chuyến đi nếu có
    if (tripId) {
      vehicles = vehicles.filter(v => v.tripId === tripId);
    }
    // Sắp xếp theo tên xe (tăng dần, ví dụ xe 01, xe 02)
    vehicles.sort((a, b) => {
      // Tách số cuối tên xe nếu có
      const getNum = (name) => {
        const match = name && name.match(/(\d+)/);
        return match ? parseInt(match[1], 10) : 0;
      };
      // So sánh theo số nếu có, nếu không thì so sánh chuỗi
      const numA = getNum(a.nameVehicle);
      const numB = getNum(b.nameVehicle);
      if (numA !== numB) return numA - numB;
      return (a.nameVehicle || '').localeCompare(b.nameVehicle || '', 'vi', { sensitivity: 'base' });
    });

    // Lấy vehicleTypes và trips để truyền vào view
    const [typesSnap, tripsSnap] = await Promise.all([
      vehicleTypeCollection.get(),
      tripCollection.get()
    ]);
    const vehicleTypes = typesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    const trips = tripsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    // Lấy giá trị search từ query (nếu có)
    const { search = '' } = req.query;

    res.render('vehicles/vehicles', { vehicles, vehicleTypes, trips, selectedVehicleTypeId: vehicleTypeId || '', selectedTripId: tripId || '', search });

  } catch (error) {
    console.error('Lỗi khi lấy danh sách phương tiện:', error);
    res.status(500).send('Lỗi server khi lấy danh sách phương tiện.');
  }
};

// POST /vehicles/add
exports.addVehicle = async (req, res) => {
  const { nameVehicle, plate, vehicleTypeId, tripId, price, startTime, endTime } = req.body;

  try {
    await vehicleCollection.add({
      nameVehicle,
      plate,
      vehicleTypeId: vehicleTypeId || null,
      tripId: tripId || null,
      price: Number(price),
      startTime,
      endTime
    });
    // Sau khi thêm, redirect về /vehicles (listVehicles sẽ truyền đủ biến)
    res.redirect('/vehicles');
  } catch (error) {
    console.error('Lỗi khi thêm phương tiện:', error);
    res.status(500).send('Lỗi khi thêm phương tiện.');
  }
};

// POST /vehicles/edit/:id
exports.updateVehicle = async (req, res) => {
  const { id } = req.params;
  const { nameVehicle, plate, vehicleTypeId, tripId, price, startTime, endTime } = req.body;

  try {
    const docRef = vehicleCollection.doc(id);
    const doc = await docRef.get();
    if (!doc.exists) return res.status(404).send('Phương tiện không tồn tại.');

    await docRef.update({
      nameVehicle,
      plate,
      vehicleTypeId: vehicleTypeId || null,
      tripId: tripId || null,
      price: Number(price),
      startTime,
      endTime
    });
    // Sau khi sửa, redirect về /vehicles (listVehicles sẽ truyền đủ biến)
    res.redirect('/vehicles');
  } catch (error) {
    console.error('Lỗi khi cập nhật phương tiện:', error);
    res.status(500).send('Lỗi khi cập nhật phương tiện.');
  }
};

// POST /vehicles/delete/:id
exports.deleteVehicle = async (req, res) => {
  const { id } = req.params;

  try {
    const docRef = vehicleCollection.doc(id);
    const doc = await docRef.get();
    if (!doc.exists) return res.status(404).send('Phương tiện không tồn tại.');

    await docRef.delete();
    res.redirect('/vehicles');
  } catch (error) {
    console.error('Lỗi khi xóa phương tiện:', error);
    res.status(500).send('Lỗi khi xóa phương tiện.');
  }
};
