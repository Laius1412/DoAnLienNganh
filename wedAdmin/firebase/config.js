const admin = require("firebase-admin");
const { initializeApp } = require("firebase/app");
const { getAuth } = require("firebase/auth");
const { getFirestore } = require("firebase/firestore");

// ⚠️ Đọc file cấu hình từ biến môi trường
if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
  throw new Error("❌ Thiếu biến môi trường FIREBASE_SERVICE_ACCOUNT");
}

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

// Admin SDK (cho backend: Firestore, xác thực admin)
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Firebase Client SDK (dùng auth từ client)
const firebaseConfig = {
  apiKey: "AIzaSyAu2Odx8m4ft8mwhIrng3xRNMqDDrAZyeQ",
  authDomain: "flash-b458d.firebaseapp.com",
  projectId: "flash-b458d",
  storageBucket: "flash-b458d.appspot.com", // 🔧 sửa đúng domain `.appspot.com`
  messagingSenderId: "652593698682",
  appId: "1:652593698682:web:b116af389e8a17c96ae8c3",
  measurementId: "G-MB04EB6Q18"
};

// Khởi tạo Firebase App cho client-side
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = admin.firestore(); // Firestore (dùng Admin SDK)

module.exports = { admin, auth, db };
