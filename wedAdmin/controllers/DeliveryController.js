// controllers/DeliveryController.js
const admin = require('firebase-admin');
const db = admin.firestore();

module.exports = {
  index: (req, res) => {
    res.render('delivery/index');
  },

  // Region
  getRegions: async (req, res) => {
    try {
      const snapshot = await db.collection('regions').get();
      const regions = snapshot.docs.map(doc => doc.data());
      res.status(200).json(regions);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  addRegion: async (req, res) => {
    const { regionId, regionName } = req.body;
    try {
      const existing = await db.collection('regions')
        .where('regionName', '==', regionName).get();

      if (!existing.empty || (await db.collection('regions').doc(regionId).get()).exists) {
        return res.status(400).json({ message: 'Khu vực đã tồn tại' });
      }

      await db.collection('regions').doc(regionId).set({ regionId, regionName });
      res.status(200).json({ message: 'Thêm khu vực thành công' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  updateRegion: async (req, res) => {
    const { id } = req.params;
    const { regionName } = req.body;
    try {
      await db.collection('regions').doc(id).update({ regionName });
      res.status(200).json({ message: 'Cập nhật thành công' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  deleteRegion: async (req, res) => {
    const { id } = req.params;
    try {
      await db.collection('regions').doc(id).delete();
      res.status(200).json({ message: 'Xóa thành công' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Office
  addOffice: async (req, res) => {
    const { officeId, officeName, regionId, address, hotline } = req.body;
    try {
      const existing = await db.collection('offices').doc(officeId).get();
      if (existing.exists) {
        return res.status(400).json({ message: 'Văn phòng đã tồn tại' });
      }

      await db.collection('offices').doc(officeId).set({
        officeId, officeName, regionId, address, hotline
      });

      res.status(200).json({ message: 'Thêm văn phòng thành công' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  updateOffice: async (req, res) => {
    const { id } = req.params;
    const { officeName, address, hotline } = req.body;
    try {
      await db.collection('offices').doc(id).update({ officeName, address, hotline });
      res.status(200).json({ message: 'Cập nhật văn phòng thành công' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  deleteOffice: async (req, res) => {
    const { id } = req.params;
    try {
      await db.collection('offices').doc(id).delete();
      res.status(200).json({ message: 'Xóa văn phòng thành công' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getOfficesByRegion: async (req, res) => {
    const { regionId } = req.params;
    try {
      const snapshot = await db.collection('offices').where('regionId', '==', regionId).get();
      const offices = snapshot.docs.map(doc => doc.data());
      res.status(200).json(offices);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getOfficeById: async (req, res) => {
    const { id } = req.params;
    try {
      const doc = await db.collection('offices').doc(id).get();
      if (!doc.exists) return res.status(404).json({ message: 'Không tìm thấy văn phòng' });
      res.status(200).json(doc.data());
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};
