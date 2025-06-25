// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(fromRegionName, toRegionName) =>
      "Delivery Price from ${fromRegionName} to ${toRegionName}";

  static String m1(regionName) => "Local Delivery Price for ${regionName}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "aboutUs": MessageLookupByLibrary.simpleMessage("About us"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "accountDisabled": MessageLookupByLibrary.simpleMessage("accountDisabled"),
    "accountNotFound": MessageLookupByLibrary.simpleMessage(
      "Account not found",
    ),
    "birthDate": MessageLookupByLibrary.simpleMessage("Birth date"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "changePasswordFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to change password",
    ),
    "checkConnection": MessageLookupByLibrary.simpleMessage(
      "Please check your network connection",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "createDelivery": MessageLookupByLibrary.simpleMessage("Create Delivery"),
    "currentPassword": MessageLookupByLibrary.simpleMessage("Current Password"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "delivery": MessageLookupByLibrary.simpleMessage("Delivery"),
    "deliveryPrice": MessageLookupByLibrary.simpleMessage("Delivery Price"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit profie"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "emailAlreadyUsed": MessageLookupByLibrary.simpleMessage(
      "Email has been used!",
    ),
    "emailOrPhone": MessageLookupByLibrary.simpleMessage(
      "Email or phone number",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterAllFields": MessageLookupByLibrary.simpleMessage(
      "Please enter all fields",
    ),
    "enterOtp": MessageLookupByLibrary.simpleMessage("Enter OTP"),
    "enterPhone": MessageLookupByLibrary.simpleMessage("Enter your phone"),
    "female": MessageLookupByLibrary.simpleMessage("Female"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "gender": MessageLookupByLibrary.simpleMessage("Gender"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "ifDontHaveAccount": MessageLookupByLibrary.simpleMessage(
      "You don\'t have an account?",
    ),
    "interRegionDeliveryPrice": m0,
    "invalidEmail": MessageLookupByLibrary.simpleMessage("Invalid email!"),
    "invalidOtp": MessageLookupByLibrary.simpleMessage("Invalid OTP"),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid 10-digit phone number starting with 0",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "localDeliveryPrice": m1,
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginFailed": MessageLookupByLibrary.simpleMessage("Login Failed"),
    "loginSuccess": MessageLookupByLibrary.simpleMessage("Login success!"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "male": MessageLookupByLibrary.simpleMessage("Male"),
    "maxWeight": MessageLookupByLibrary.simpleMessage("Max Weight (kg)"),
    "minWeight": MessageLookupByLibrary.simpleMessage("Min Weight (kg)"),
    "myDeliveries": MessageLookupByLibrary.simpleMessage("My Deliveries"),
    "myTickets": MessageLookupByLibrary.simpleMessage("My Tickets"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "noConnection": MessageLookupByLibrary.simpleMessage(
      "No network connection",
    ),
    "noPriceDataAvailable": MessageLookupByLibrary.simpleMessage(
      "No price data available.",
    ),
    "notificationSettings": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordChangedSuccess": MessageLookupByLibrary.simpleMessage(
      "Password changed successfully",
    ),
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match!",
    ),
    "passwordTooShort": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Phone number"),
    "phoneAlreadyUsed": MessageLookupByLibrary.simpleMessage(
      "Phone have already been used!",
    ),
    "phoneVerification": MessageLookupByLibrary.simpleMessage(
      "Phone Verification",
    ),
    "pleaseLogin": MessageLookupByLibrary.simpleMessage("Please login"),
    "policy": MessageLookupByLibrary.simpleMessage("Policy"),
    "price": MessageLookupByLibrary.simpleMessage("Price (VND)"),
    "register": MessageLookupByLibrary.simpleMessage("Register"),
    "registerFailed": MessageLookupByLibrary.simpleMessage("Register failed!"),
    "registerSuccess": MessageLookupByLibrary.simpleMessage(
      "Register success!",
    ),
    "rememberMe": MessageLookupByLibrary.simpleMessage("Remember me"),
    "requiredField": MessageLookupByLibrary.simpleMessage("Required field"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "sendCode": MessageLookupByLibrary.simpleMessage("Send code"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "tapToSelect": MessageLookupByLibrary.simpleMessage("Tap to select"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "trackDelivery": MessageLookupByLibrary.simpleMessage("Track Delivery"),
    "verificationFailed": MessageLookupByLibrary.simpleMessage(
      "Verification Failed",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "vietnamese": MessageLookupByLibrary.simpleMessage("Vietnamese"),
    "weakPassword": MessageLookupByLibrary.simpleMessage(
      "Password is too weak!",
    ),
    "wrongPassword": MessageLookupByLibrary.simpleMessage("Wrong Password"),
  };
}
