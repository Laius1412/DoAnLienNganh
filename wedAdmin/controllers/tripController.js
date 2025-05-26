const { db } = require("../firebase/config");

// Lấy danh sách chuyến đi
exports.getTrips = async (req, res) => {
  try {
    const snapshot = await db.collection("trip").get();
    const trips = [];

    snapshot.forEach(doc => {
      const data = doc.data();
      trips.push({
        id: doc.id,
        tripCode: data.tripCode,
        nameTrip: data.nameTrip,
        vRouter: data.vRouter,
        startLocation: data.startLocation,
        destination: data.destination,
      });
    });

    // Lấy lỗi và dữ liệu add/edit từ session
    const addTripError = req.session.addTripError;
    const addTripData = req.session.addTripData;
    const editTripError = req.session.editTripError;
    const editTripData = req.session.editTripData;

    // Xóa session lỗi sau khi lấy để không hiển thị lại
    req.session.addTripError = null;
    req.session.addTripData = null;
    req.session.editTripError = null;
    req.session.editTripData = null;

    res.render("trips/trips", { layout: "layout", trips, addTripError, addTripData, editTripError, editTripData });
  } catch (err) {
    console.error("Lỗi khi lấy danh sách chuyến đi:", err);
    res.status(500).send("Lỗi server");
  }
};


// Thêm chuyến đi
exports.addTrip = async (req, res) => {
  try {
    const {tripCode, nameTrip, vRouter, startLocation, destination} = req.body;

    const snapshot = await db.collection("trip").where("tripCode", "==", tripCode).get();
    if (!snapshot.empty) {
      // Lưu lỗi và dữ liệu vào session để hiển thị lại
      req.session.addTripError = "Mã chuyến đã tồn tại, vui lòng nhập mã khác";
      req.session.addTripData = { tripCode, nameTrip, vRouter, startLocation, destination };
      return res.redirect("/trips");
    }

    await db.collection("trip").add({ tripCode, nameTrip, vRouter, startLocation, destination });

    // Xóa session sau khi thành công
    req.session.addTripError = null;
    req.session.addTripData = null;

    res.redirect("/trips");
  } catch (err) {
    console.error("Lỗi khi thêm chuyến đi:", err);
    res.status(500).send("Lỗi server");
  }
};

// Sửa chuyến đi
exports.updateTrip = async (req, res) => {
  try {
    const id = req.params.id;
    if (!id) return res.status(400).send("Thiếu ID chuyến đi để cập nhật");

    const { tripCode, nameTrip, vRouter, startLocation, destination } = req.body;

    const snapshot = await db.collection("trip")
      .where("tripCode", "==", tripCode)
      .get();

    const existsDuplicate = snapshot.docs.some(doc => doc.id !== id);
    if (existsDuplicate) {
      // Lưu lỗi và dữ liệu để hiển thị lại modal sửa
      req.session.editTripError = "Mã chuyến đã tồn tại, vui lòng nhập mã khác";
      req.session.editTripData = { id, tripCode, nameTrip, vRouter, startLocation, destination };
      return res.redirect("/trips");
    }

    const tripRef = db.collection("trip").doc(id);
    const tripDoc = await tripRef.get();
    if (!tripDoc.exists) return res.status(404).send("Không tìm thấy chuyến đi để cập nhật");

    await tripRef.update({ tripCode, nameTrip, vRouter, startLocation, destination });

    req.session.editTripError = null;
    req.session.editTripData = null;

    res.redirect("/trips");
  } catch (err) {
    console.error("Lỗi khi cập nhật chuyến đi:", err);
    res.status(500).send("Lỗi server");
  }
};


// Sửa chuyến đi, kiểm tra tripCode không trùng với chuyến đi khác
exports.updateTrip = async (req, res) => {
  try {
    const id = req.params.id;
    if (!id) return res.status(400).send("Thiếu ID chuyến đi để cập nhật");

    const { tripCode, nameTrip, vRouter, startLocation, destination } = req.body;

    // Kiểm tra tripCode trùng (ngoại trừ chính chuyến đi đang sửa)
    const snapshot = await db.collection("trip")
      .where("tripCode", "==", tripCode)
      .get();

    const existsDuplicate = snapshot.docs.some(doc => doc.id !== id);
    if (existsDuplicate) {
      return res.redirect("/trips?error=Mã chuyến đã tồn tại, vui lòng nhập mã khác");
    }

    const tripRef = db.collection("trip").doc(id);
    const tripDoc = await tripRef.get();

    if (!tripDoc.exists) {
      return res.status(404).send("Không tìm thấy chuyến đi để cập nhật");
    }

    await tripRef.update({
      tripCode,
      nameTrip,
      vRouter,
      startLocation,
      destination,
    });

    res.redirect("/trips");
  } catch (err) {
    console.error("Lỗi khi cập nhật chuyến đi:", err);
    res.status(500).send("Lỗi server");
  }
};

// Xóa chuyến đi
exports.deleteTrip = async (req, res) => {
  try {
    const id = req.params.id;
    if (!id) return res.status(400).send("Thiếu ID chuyến đi để xóa");

    await db.collection("trip").doc(id).delete();
    res.redirect("/trips");
  } catch (err) {
    console.error("Lỗi khi xóa chuyến đi:", err);
    res.status(500).send("Lỗi server");
  }
};

// Xóa nhiều chuyến đi
exports.deleteMultipleTrips = async (req, res) => {
  try {
    const ids = req.body.selectedIds;
    if (!ids) {
      return res.redirect("/trips");
    }

    // Nếu ids là chuỗi (1 phần tử), convert thành mảng
    const idsArray = Array.isArray(ids) ? ids : [ids];

    const batch = db.batch();
    idsArray.forEach(id => {
      const docRef = db.collection("trip").doc(id);
      batch.delete(docRef);
    });
    await batch.commit();

    res.redirect("/trips");
  } catch (err) {
    console.error("Lỗi khi xóa nhiều chuyến đi:", err);
    res.status(500).send("Lỗi server");
  }
};
