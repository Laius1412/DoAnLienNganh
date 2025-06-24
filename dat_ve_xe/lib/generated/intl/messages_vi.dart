// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  static String m0(fromRegionName, toRegionName) =>
      "Bảng giá cước chuyển phát ${fromRegionName} - ${toRegionName}";

  static String m1(regionName) =>
      "Bảng giá cước chuyển phát khu vực ${regionName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutUs": MessageLookupByLibrary.simpleMessage("Giới thiệu"),
    "account": MessageLookupByLibrary.simpleMessage("Tài khoản"),
    "accountDisabled": MessageLookupByLibrary.simpleMessage(
      "Tài khoản bị vô hiệu hóa",
    ),
    "accountNotFound": MessageLookupByLibrary.simpleMessage(
      "Tài khoản không chính xác hoặc không tồn tại",
    ),
    "birthDate": MessageLookupByLibrary.simpleMessage("Ngày sinh"),
    "cancel": MessageLookupByLibrary.simpleMessage("Đóng"),
    "changePassword": MessageLookupByLibrary.simpleMessage("Đổi mật khẩu"),
    "changePasswordFailed": MessageLookupByLibrary.simpleMessage(
      "Đổi mật khẩu thất bại",
    ),
    "checkConnection": MessageLookupByLibrary.simpleMessage(
      "Vui lòng kiểm tra kết nối mạng của bạn",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "Xác nhận mật khẩu",
    ),
    "createDelivery": MessageLookupByLibrary.simpleMessage("Tạo đơn hàng"),
    "currentPassword": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu hiện tại",
    ),
    "darkMode": MessageLookupByLibrary.simpleMessage("Chế độ tối"),
    "delivery": MessageLookupByLibrary.simpleMessage("Chuyển phát"),
    "deliveryPrice": MessageLookupByLibrary.simpleMessage(
      "Bảng giá chuyển phát",
    ),
    "editProfile": MessageLookupByLibrary.simpleMessage(
      "Chỉnh sửa thông tin cá nhân",
    ),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailAlreadyUsed": MessageLookupByLibrary.simpleMessage(
      "Email đã được sử dụng!",
    ),
    "emailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Email hoặc số điện thoại",
    ),
    "english": MessageLookupByLibrary.simpleMessage("Tiếng Anh"),
    "enterAllFields": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập đầy đủ thông tin",
    ),
    "enterOtp": MessageLookupByLibrary.simpleMessage("Nhập mã OTP"),
    "enterPhone": MessageLookupByLibrary.simpleMessage("Nhập số điện thoại"),
    "female": MessageLookupByLibrary.simpleMessage("Nữ"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Quên mật khẩu?"),
    "gender": MessageLookupByLibrary.simpleMessage("Giới tính"),
    "home": MessageLookupByLibrary.simpleMessage("Trang chủ"),
    "ifDontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Bạn chưa có tài khoản?",
    ),
    "interRegionDeliveryPrice": m0,
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "Email không đúng hoặc không tồn tại",
    ),
    "invalidOtp": MessageLookupByLibrary.simpleMessage(
      "Mã OTP không chính xác",
    ),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "Vui lòng nhập số điện thoại hợp lệ gồm 10 chữ số và bắt đầu bằng số 0",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Ngôn ngữ"),
    "localDeliveryPrice": m1,
    "login": MessageLookupByLibrary.simpleMessage("Đăng nhập"),
    "loginFailed": MessageLookupByLibrary.simpleMessage("Đăng nhập thất bại"),
    "loginSuccess": MessageLookupByLibrary.simpleMessage(
      "Đăng nhập thành công!",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Đăng xuất"),
    "male": MessageLookupByLibrary.simpleMessage("Nam"),
    "maxWeight": MessageLookupByLibrary.simpleMessage("Khối lượng tối đa(kg)"),
    "minWeight": MessageLookupByLibrary.simpleMessage(
      "Khối lượng tối thiểu(kg)",
    ),
    "myDeliveries": MessageLookupByLibrary.simpleMessage("Đơn hàng của tôi"),
    "myTickets": MessageLookupByLibrary.simpleMessage("Vé của tôi"),
    "name": MessageLookupByLibrary.simpleMessage("Họ và tên"),
    "newPassword": MessageLookupByLibrary.simpleMessage("Mật khẩu mới"),
    "noConnection": MessageLookupByLibrary.simpleMessage(
      "Không có kết nối mạng",
    ),
    "noPriceDataAvailable": MessageLookupByLibrary.simpleMessage(
      "Không có dữ liệu giá nào.",
    ),
    "notificationSettings": MessageLookupByLibrary.simpleMessage(
      "Cài đặt thông báo",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Thông báo"),
    "password": MessageLookupByLibrary.simpleMessage("Mật khẩu"),
    "passwordChangedSuccess": MessageLookupByLibrary.simpleMessage(
      "Đổi mật khẩu thành công",
    ),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu không trùng khớp!",
    ),
    "passwordTooShort": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu phải có ít nhất 6 ký tự",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Số điện thoại"),
    "phoneAlreadyUsed": MessageLookupByLibrary.simpleMessage(
      "Số điện thoại đã được sử dụng!",
    ),
    "phoneVerification": MessageLookupByLibrary.simpleMessage(
      "Xác thực số điện thoại",
    ),
    "pleaseLogin": MessageLookupByLibrary.simpleMessage("Vui lòng đăng nhập"),
    "policy": MessageLookupByLibrary.simpleMessage("Chính sách"),
    "price": MessageLookupByLibrary.simpleMessage("Giá cước(VND)"),
    "register": MessageLookupByLibrary.simpleMessage("Đăng ký"),
    "registerFailed": MessageLookupByLibrary.simpleMessage("Đăng ký thất bại!"),
    "registerSuccess": MessageLookupByLibrary.simpleMessage(
      "Đăng ký thành công!",
    ),
    "rememberMe": MessageLookupByLibrary.simpleMessage("Nhớ mật khẩu"),
    "requiredField": MessageLookupByLibrary.simpleMessage("Yêu cầu bắt buộc"),
    "retry": MessageLookupByLibrary.simpleMessage("Thử lại"),
    "sendCode": MessageLookupByLibrary.simpleMessage("Gửi mã"),
    "settings": MessageLookupByLibrary.simpleMessage("Cài đặt"),
    "tapToSelect": MessageLookupByLibrary.simpleMessage("Chạm để chọn ngày"),
    "theme": MessageLookupByLibrary.simpleMessage("Giao diện"),
    "trackDelivery": MessageLookupByLibrary.simpleMessage("Tra cứu đơn hàng"),
    "verificationFailed": MessageLookupByLibrary.simpleMessage(
      "Xác thực thất bại",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("Xác thực"),
    "vietnamese": MessageLookupByLibrary.simpleMessage("Tiếng Việt"),
    "weakPassword": MessageLookupByLibrary.simpleMessage("Mật khẩu quá yếu!"),
    "wrongPassword": MessageLookupByLibrary.simpleMessage(
      "Mật khẩu không chính xác",
    ),
  };
}
