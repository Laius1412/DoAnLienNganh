// firebase/config.js
const admin = require("firebase-admin");
const { initializeApp } = require("firebase/app");
const { getAuth } = require("firebase/auth");
const serviceAccount = require("./firebase-adminsdk.json"); // bạn cần tải file này từ Firebase Console

// Firebase Admin SDK cho xử lý phía server
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firebaseConfig = {
  apiKey: "AIzaSyAu2Odx8m4ft8mwhIrng3xRNMqDDrAZyeQ",
  authDomain: "flash-b458d.firebaseapp.com",
  projectId: "flash-b458d",
  storageBucket: "flash-b458d.firebasestorage.app",
  messagingSenderId: "652593698682",
  appId: "1:652593698682:web:b116af389e8a17c96ae8c3",
  measurementId: "G-MB04EB6Q18"
};

// Client SDK cho frontend
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

module.exports = { admin, auth };
