// controllers/firebase/config.js
const admin = require("firebase-admin");

// Lấy serviceAccount từ biến môi trường
const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

// Khởi tạo Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "flash-b458d.appspot.com"  // nếu bạn dùng bucket
});

const db = admin.firestore();
const auth = admin.auth();

module.exports = { admin, auth, db };
