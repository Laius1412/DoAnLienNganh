// firebase/config.js
const admin = require("firebase-admin");
const { initializeApp } = require("firebase/app");
const { getAuth } = require("firebase/auth");
const { getFirestore } = require("firebase/firestore");
const serviceAccount = require("./firebase-adminsdk.json");

// Admin SDK (dùng cho backend)
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

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = admin.firestore(); // 🔥 Dùng Admin SDK cho backend

module.exports = { admin, auth, db };
