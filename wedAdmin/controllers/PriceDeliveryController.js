const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();

exports.getPriceDeliveryPage = (req, res) => {
    res.render('delivery/price_delivery');
};

exports.getRegions = async (req, res) => {
    try {
        const regionsSnap = await db.collection('regions').get();
        const regions = regionsSnap.docs.map(doc => doc.data());
        res.json(regions);
    } catch (error) {
        console.error('Error getting regions:', error);
        res.status(500).json({ error: 'Lỗi khi lấy danh sách khu vực' });
    }
};

exports.getPriceDeliveryList = async (req, res) => {
    try {
        const priceSnap = await db.collection('priceDelivery').get();
        const list = priceSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.json(list);
    } catch (error) {
        console.error('Error getting price list:', error);
        res.status(500).json({ error: 'Lỗi khi lấy danh sách bảng giá' });
    }
};

function isEmpty(val) {
    return val === undefined || val === null || val === '';
}

exports.createPriceDelivery = async (req, res) => {
    try {
        const { fromRegionId, toRegionId, weightRanges } = req.body;

        // Validate input
        if (isEmpty(fromRegionId) || isEmpty(toRegionId)) {
            return res.status(400).json({ error: 'Vui lòng chọn khu vực' });
        }
        if (!Array.isArray(weightRanges) || weightRanges.length === 0) {
            return res.status(400).json({ error: 'Vui lòng nhập ít nhất một mức giá' });
        }
        for (const range of weightRanges) {
            if (isEmpty(range.min) || isEmpty(range.max) || isEmpty(range.price)) {
                return res.status(400).json({ error: 'Vui lòng nhập đầy đủ thông tin cho các mức giá' });
            }
            if (parseFloat(range.min) >= parseFloat(range.max)) {
                return res.status(400).json({ error: 'Khối lượng tối thiểu phải nhỏ hơn khối lượng tối đa' });
            }
            if (parseFloat(range.price) <= 0) {
                return res.status(400).json({ error: 'Giá cước phải lớn hơn 0' });
            }
        }

        // Ghép 2 regionId làm docId
        const docId = fromRegionId + toRegionId;
        const docRef = db.collection('priceDelivery').doc(docId);
        await docRef.set({
            fromRegionId,
            toRegionId,
            weightRanges,
            createdAt: new Date().toISOString()
        });
        return res.status(200).json({ success: true, id: docId });
    } catch (error) {
        console.error('Error creating price delivery:', error);
        return res.status(500).json({ error: 'Lỗi khi tạo bảng giá' });
    }
};

exports.updatePriceDelivery = async (req, res) => {
    try {
        const { id } = req.params;
        const { fromRegionId, toRegionId, weightRanges } = req.body;

        // Validate input
        if (isEmpty(fromRegionId) || isEmpty(toRegionId)) {
            return res.status(400).json({ error: 'Vui lòng chọn khu vực' });
        }
        if (!Array.isArray(weightRanges) || weightRanges.length === 0) {
            return res.status(400).json({ error: 'Vui lòng nhập ít nhất một mức giá' });
        }
        for (const range of weightRanges) {
            if (isEmpty(range.min) || isEmpty(range.max) || isEmpty(range.price)) {
                return res.status(400).json({ error: 'Vui lòng nhập đầy đủ thông tin cho các mức giá' });
            }
            if (parseFloat(range.min) >= parseFloat(range.max)) {
                return res.status(400).json({ error: 'Khối lượng tối thiểu phải nhỏ hơn khối lượng tối đa' });
            }
            if (parseFloat(range.price) <= 0) {
                return res.status(400).json({ error: 'Giá cước phải lớn hơn 0' });
            }
        }

        // Check if document exists
        const docRef = db.collection('priceDelivery').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Không tìm thấy bảng giá' });
        }

        // Chỉ cập nhật các trường cần thiết, giữ nguyên các trường khác
        await docRef.update({
            fromRegionId,
            toRegionId,
            weightRanges,
            updatedAt: new Date().toISOString()
        });
        return res.status(200).json({ success: true });
    } catch (error) {
        console.error('Error updating price delivery:', error);
        return res.status(500).json({ error: 'Lỗi khi cập nhật bảng giá' });
    }
};

exports.deletePriceDeliveries = async (req, res) => {
    try {
        const { ids } = req.body;
        if (!Array.isArray(ids) || ids.length === 0) {
            return res.status(400).json({ error: 'Vui lòng chọn ít nhất một bảng giá để xóa' });
        }
        const batch = db.batch();
        ids.forEach(id => {
            const ref = db.collection('priceDelivery').doc(id);
            batch.delete(ref);
        });
        await batch.commit();
        return res.status(200).json({ success: true });
    } catch (error) {
        console.error('Error deleting price deliveries:', error);
        return res.status(500).json({ error: 'Lỗi khi xóa bảng giá' });
    }
};