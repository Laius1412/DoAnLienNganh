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
  },

  // Lấy danh sách đơn hàng giao hàng
  getDeliveryOrders: async (req, res) => {
    const snapshot = await db.collection('deliveryOrders').get();
    const data = snapshot.docs.map(doc => {
      const order = doc.data();
      // Nếu order.createdAt là Firestore Timestamp
      if (order.createdAt && order.createdAt.toDate) {
        order.createdAt = order.createdAt.toDate().toISOString();
      }
      // Nếu là số thì giữ nguyên
      return order;
    });
    res.json({ data });
  },

  // Lấy danh sách users
  getUsers: async (req, res) => {
    try {
      const snapshot = await db.collection('users').get();
      const users = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      res.status(200).json({ data: users });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  // Cập nhật đơn hàng giao hàng và tạo deliveryNotice
  updateDeliveryOrder: async (req, res) => {
    const { id } = req.params;
    const { mass, status } = req.body;
    try {
      const orderRef = db.collection('deliveryOrders').doc(id);
      const orderDoc = await orderRef.get();
      if (!orderDoc.exists) return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
      const oldData = orderDoc.data();
      const updatedAt = new Date();
      await orderRef.update({ mass, status, updatedAt });
      
      // Tạo deliveryNotice và gửi FCM notification
      const userId = oldData.userId || oldData.userID || oldData.user_id || '';
      console.log('Delivery order userId:', userId);
      
      let fcmToken = '';
      if (userId) {
        const userDoc = await db.collection('users').doc(userId).get();
        if (userDoc.exists) {
          fcmToken = userDoc.data().fcmToken || '';
          console.log('User FCM token:', fcmToken);
        } else {
          console.log('User document not found for userId:', userId);
        }
      } else {
        console.log('No userId found in delivery order');
      }
      
      const statusMap = {
        pending: 'chờ xác nhận',
        confirmed: 'đã được xác nhận',
        accepted: 'đã tiếp nhận',
        delivering: 'đang vận chuyển',
        delivered: 'đã tới nơi',
        returning: 'đang hoàn trả',
        returned: 'đã hoàn trả',
        received: 'người nhận đã nhận hàng',
        refused: 'từ chối nhận hàng',
      };
      
      const title = `Thông tin đơn hàng ${id}`;
      const body = `Đơn hàng ${id} ${statusMap[status] || status}`;
      
      // Lưu vào Firestore collection deliveryNotice
      await db.collection('deliveryNotice').add({
        userId,
        fcmToken,
        title,
        body,
        timestamp: updatedAt,
        isRead: false,
        type: 'delivery',
        orderId: id
      });
      
      // Gửi FCM notification nếu có fcmToken
      if (fcmToken) {
        console.log('Sending FCM notification to token:', fcmToken);
        try {
          const message = {
            token: fcmToken,
            notification: {
              title: title,
              body: body,
            },
            data: {
              type: 'delivery',
              orderId: id,
              click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            android: {
              notification: {
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                channelId: 'delivery_notifications',
                priority: 'high',
                defaultSound: true,
                defaultVibrateTimings: true,
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          };
          
          console.log('FCM message payload:', JSON.stringify(message, null, 2));
          const response = await admin.messaging().send(message);
          console.log('FCM notification sent successfully:', response);
        } catch (fcmError) {
          console.error('Error sending FCM notification:', fcmError);
          console.error('FCM error details:', fcmError.message);
        }
      } else {
        console.log('No FCM token available, skipping notification');
      }
      
      res.status(200).json({ message: 'Cập nhật thành công' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getOffices: async (req, res) => {
    try {
      const snapshot = await db.collection('offices').get();
      const offices = snapshot.docs.map(doc => doc.data());
      res.status(200).json({ data: offices });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  orderManagePage: (req, res) => {
    res.render('delivery/order_manage');
  },

  // Test endpoint để gửi FCM notification
  testFCMNotification: async (req, res) => {
    const { userId, fcmToken } = req.body;
    
    try {
      console.log('Testing FCM notification for userId:', userId);
      console.log('FCM token:', fcmToken);
      
      if (!fcmToken) {
        return res.status(400).json({ error: 'FCM token is required' });
      }
      
      const message = {
        token: fcmToken,
        notification: {
          title: 'Test Notification',
          body: 'Đây là thông báo test từ web admin',
        },
        data: {
          type: 'delivery',
          orderId: 'test-123',
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        },
        android: {
          notification: {
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            channelId: 'delivery_notifications',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
      };
      
      console.log('Sending test FCM message:', JSON.stringify(message, null, 2));
      const response = await admin.messaging().send(message);
      console.log('Test FCM notification sent successfully:', response);
      
      res.status(200).json({ 
        message: 'Test notification sent successfully',
        response: response 
      });
    } catch (error) {
      console.error('Error sending test FCM notification:', error);
      res.status(500).json({ error: error.message });
    }
  }
};
