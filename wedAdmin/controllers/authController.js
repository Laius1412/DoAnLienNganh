const { auth } = require('../firebase/config');
const { signInWithEmailAndPassword } = require("firebase/auth");

exports.loginPage = (req, res) => {
  res.render('auth/login', { 
    layout: false,
    error: null });
};

exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    req.session.user = userCredential.user;
    res.redirect('/dashboard');
  } catch (err) {
    res.render('auth/login', { error: 'Sai email hoặc mật khẩu' });
  }
};

exports.logoutUser = (req, res) => {
  req.session.destroy(() => {
    res.redirect('/login');
  });
};
