const express = require('express');
const session = require('express-session');
const path = require('path');
const expressLayouts = require('express-ejs-layouts');

const app = express();
const authRoutes = require('./routes/auth');
const dashboardRoutes = require('./routes/dashboard');

// Middleware đọc dữ liệu từ form
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(expressLayouts);
app.set('layout', 'layout');

// Static
app.use(express.static(path.join(__dirname, 'public')));

// Session
app.use(session({
  secret: 'my_secret_key',
  resave: false,
  saveUninitialized: false,
}));

// Routes
app.use('/', authRoutes);
app.use('/dashboard', dashboardRoutes);

// Root
app.get("/", (req, res) => {
  res.redirect("/login");
});
const userRoutes = require('./routes/user');
app.use('/user', userRoutes);
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Server chạy tại http://localhost:${PORT}`));
