const { db } = require("../firebase/config");

const vehicleCollection = db.collection('vehicle');
const vehicleTypeCollection = db.collection('vehicleType');
const tripCollection = db.collection('trip');

// GET /vehicles
exports.listVehicles = async (req, res) => {
  try {
    const snapshot = await vehicleCollection.get();
    const vehicles = [];

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

    res.render('vehicles/list', { vehicles });

  } catch (error) {
    console.error('Lỗi khi lấy danh sách phương tiện:', error);
    res.status(500).send('Lỗi server khi lấy danh sách phương tiện.');
  }
};

// GET /vehicles/add
exports.renderAddForm = async (req, res) => {
  try {
    const [typesSnap, tripsSnap] = await Promise.all([
      vehicleTypeCollection.get(),
      tripCollection.get()
    ]);

    const vehicleTypes = typesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    const trips = tripsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.render('vehicles/add', { vehicleTypes, trips });

  } catch (error) {
    console.error('Lỗi khi hiển thị form thêm:', error);
    res.status(500).send('Lỗi khi hiển thị form thêm.');
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

    res.redirect('/vehicles');
  } catch (error) {
    console.error('Lỗi khi thêm phương tiện:', error);
    res.status(500).send('Lỗi khi thêm phương tiện.');
  }
};

// GET /vehicles/edit/:id
exports.renderEditForm = async (req, res) => {
  const { id } = req.params;

  try {
    const doc = await vehicleCollection.doc(id).get();
    if (!doc.exists) return res.status(404).send('Phương tiện không tồn tại.');

    const vehicle = { id: doc.id, ...doc.data() };

    const [typesSnap, tripsSnap] = await Promise.all([
      vehicleTypeCollection.get(),
      tripCollection.get()
    ]);

    const vehicleTypes = typesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    const trips = tripsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.render('vehicles/edit', { vehicle, vehicleTypes, trips });

  } catch (error) {
    console.error('Lỗi khi hiển thị form sửa:', error);
    res.status(500).send('Lỗi khi hiển thị form sửa.');
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
