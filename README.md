# Thành viên dự án:

## Cao Mậu Thành Đạt
## Nguyễn Trần Việt Anh
## Võ Quang Giáp

# I. Giới thiệu chung

## 1. Tên dự án: Flash Travel

## 2. Mô tả:

- Dự án phần mềm cho doanh nghiệp kinh doanh dịch vụ vận tải khách và hàng hóa.
- Phần mềm bao gồm trang web quản lý dành cho doanh nghiệp (quản trị viên) và ứng dụng di động đặt vé cho người dùng.
- Với các nhóm chức năng chính là đặt vé, vận chuyển hàng hóa, xem tin tức,...

## 3. Công cụ sử dụng:

- Website quản lý: Framework ExpressJS (NodeJS, Html, Css, Js).
- App mobile: Flutter Platform (Dart, C++)
- Database: Firebase, Cloudinary.

# II. Kiến trúc dự án

- **/dat_ve_xe/**: Ứng dụng di động Flutter cho người dùng cuối (đặt vé, vận chuyển hàng hóa, xem tin tức, quản lý tài khoản,...)
- **/wedAdmin/**: Trang web quản trị dành cho doanh nghiệp (quản lý chuyến xe, người dùng, đơn hàng, tin tức,...)

# III. Hướng dẫn cài đặt & chạy dự án

## 1. Web Admin (ExpressJS)

### Yêu cầu:
- Node.js >= 14.x
- npm

### Cài đặt:
```bash
cd wedAdmin
npm install
```

### Chạy server:
```bash
npm start
```
Mặc định server chạy ở cổng 3000 (có thể cấu hình lại trong code).

## 2. Ứng dụng di động (Flutter)

### Yêu cầu:
- Flutter SDK >= 3.x
- Dart >= 2.17.x
- Android Studio/Xcode (tùy nền tảng build)

### Cài đặt:
```bash
cd dat_ve_xe
flutter pub get
```

### Chạy ứng dụng:
- Android: `flutter run`
- iOS: `flutter run`
- Web: `flutter run -d chrome`

# IV. Chức năng chính

## 1. Web Admin

- Quản lý người dùng, tài xế, phương tiện, chuyến xe
- Quản lý đặt vé, đơn hàng vận chuyển
- Quản lý tin tức, thông báo
- Thống kê, báo cáo
- Đăng nhập, phân quyền quản trị

## 2. Ứng dụng di động

- Đăng ký, đăng nhập, quản lý tài khoản
- Đặt vé xe khách, xem lịch sử đặt vé
- Đặt dịch vụ vận chuyển hàng hóa
- Xem tin tức, thông báo từ doanh nghiệp
- Thanh toán trực tuyến, chuyển khoản ngân hàng
- Đổi mật khẩu, cập nhật thông tin cá nhân

# V. Công nghệ sử dụng

- **Backend/Web Admin**: NodeJS, ExpressJS, EJS, Firebase Admin SDK, Cloudinary, JWT, Multer,...
- **Mobile App**: Flutter, Firebase (Auth, Firestore, Storage, Messaging), Cloudinary, Provider,...
- **Database**: Firebase (Realtime Database/Firestore), Cloudinary (lưu trữ hình ảnh)

