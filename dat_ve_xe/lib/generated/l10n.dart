// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `My Tickets`
  String get myTickets {
    return Intl.message('My Tickets', name: 'myTickets', desc: '', args: []);
  }

  /// `Delivery`
  String get delivery {
    return Intl.message('Delivery', name: 'delivery', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Notification Settings`
  String get notificationSettings {
    return Intl.message(
      'Notification Settings',
      name: 'notificationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Policy`
  String get policy {
    return Intl.message('Policy', name: 'policy', desc: '', args: []);
  }

  /// `About us`
  String get aboutUs {
    return Intl.message('About us', name: 'aboutUs', desc: '', args: []);
  }

  /// `Email or phone number`
  String get emailOrPhone {
    return Intl.message(
      'Email or phone number',
      name: 'emailOrPhone',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `You don't have an account?`
  String get ifDontHaveAccount {
    return Intl.message(
      'You don\'t have an account?',
      name: 'ifDontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Edit profie`
  String get editProfile {
    return Intl.message('Edit profie', name: 'editProfile', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Vietnamese`
  String get vietnamese {
    return Intl.message('Vietnamese', name: 'vietnamese', desc: '', args: []);
  }

  /// `Verification Failed`
  String get verificationFailed {
    return Intl.message(
      'Verification Failed',
      name: 'verificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid OTP`
  String get invalidOtp {
    return Intl.message('Invalid OTP', name: 'invalidOtp', desc: '', args: []);
  }

  /// `Phone Verification`
  String get phoneVerification {
    return Intl.message(
      'Phone Verification',
      name: 'phoneVerification',
      desc: '',
      args: [],
    );
  }

  /// `Enter your phone`
  String get enterPhone {
    return Intl.message(
      'Enter your phone',
      name: 'enterPhone',
      desc: '',
      args: [],
    );
  }

  /// `Enter OTP`
  String get enterOtp {
    return Intl.message('Enter OTP', name: 'enterOtp', desc: '', args: []);
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `Send code`
  String get sendCode {
    return Intl.message('Send code', name: 'sendCode', desc: '', args: []);
  }

  /// `Passwords do not match!`
  String get passwordMismatch {
    return Intl.message(
      'Passwords do not match!',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Required field`
  String get requiredField {
    return Intl.message(
      'Required field',
      name: 'requiredField',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Birth date`
  String get birthDate {
    return Intl.message('Birth date', name: 'birthDate', desc: '', args: []);
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter all fields`
  String get enterAllFields {
    return Intl.message(
      'Please enter all fields',
      name: 'enterAllFields',
      desc: '',
      args: [],
    );
  }

  /// `Account not found`
  String get accountNotFound {
    return Intl.message(
      'Account not found',
      name: 'accountNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Password`
  String get wrongPassword {
    return Intl.message(
      'Wrong Password',
      name: 'wrongPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login Failed`
  String get loginFailed {
    return Intl.message(
      'Login Failed',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `Remember me`
  String get rememberMe {
    return Intl.message('Remember me', name: 'rememberMe', desc: '', args: []);
  }

  /// `Phone number`
  String get phone {
    return Intl.message('Phone number', name: 'phone', desc: '', args: []);
  }

  /// `Please enter a valid 10-digit phone number starting with 0`
  String get invalidPhone {
    return Intl.message(
      'Please enter a valid 10-digit phone number starting with 0',
      name: 'invalidPhone',
      desc: '',
      args: [],
    );
  }

  /// `Register success!`
  String get registerSuccess {
    return Intl.message(
      'Register success!',
      name: 'registerSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Register failed!`
  String get registerFailed {
    return Intl.message(
      'Register failed!',
      name: 'registerFailed',
      desc: '',
      args: [],
    );
  }

  /// `Email has been used!`
  String get emailAlreadyUsed {
    return Intl.message(
      'Email has been used!',
      name: 'emailAlreadyUsed',
      desc: '',
      args: [],
    );
  }

  /// `Password is too weak!`
  String get weakPassword {
    return Intl.message(
      'Password is too weak!',
      name: 'weakPassword',
      desc: '',
      args: [],
    );
  }

  /// `Tap to select`
  String get tapToSelect {
    return Intl.message(
      'Tap to select',
      name: 'tapToSelect',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email!`
  String get invalidEmail {
    return Intl.message(
      'Invalid email!',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Login success!`
  String get loginSuccess {
    return Intl.message(
      'Login success!',
      name: 'loginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `accountDisabled`
  String get accountDisabled {
    return Intl.message(
      'accountDisabled',
      name: 'accountDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Please login`
  String get pleaseLogin {
    return Intl.message(
      'Please login',
      name: 'pleaseLogin',
      desc: '',
      args: [],
    );
  }

  /// `Phone have already been used!`
  String get phoneAlreadyUsed {
    return Intl.message(
      'Phone have already been used!',
      name: 'phoneAlreadyUsed',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPassword {
    return Intl.message(
      'Current Password',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully`
  String get passwordChangedSuccess {
    return Intl.message(
      'Password changed successfully',
      name: 'passwordChangedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to change password`
  String get changePasswordFailed {
    return Intl.message(
      'Failed to change password',
      name: 'changePasswordFailed',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordTooShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Price`
  String get deliveryPrice {
    return Intl.message(
      'Delivery Price',
      name: 'deliveryPrice',
      desc: '',
      args: [],
    );
  }

  /// `Create Delivery`
  String get createDelivery {
    return Intl.message(
      'Create Delivery',
      name: 'createDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Track Delivery`
  String get trackDelivery {
    return Intl.message(
      'Track Delivery',
      name: 'trackDelivery',
      desc: '',
      args: [],
    );
  }

  /// `My Deliveries`
  String get myDeliveries {
    return Intl.message(
      'My Deliveries',
      name: 'myDeliveries',
      desc: '',
      args: [],
    );
  }

  /// `Min Weight (kg)`
  String get minWeight {
    return Intl.message(
      'Min Weight (kg)',
      name: 'minWeight',
      desc: '',
      args: [],
    );
  }

  /// `Max Weight (kg)`
  String get maxWeight {
    return Intl.message(
      'Max Weight (kg)',
      name: 'maxWeight',
      desc: '',
      args: [],
    );
  }

  /// `Price (VND)`
  String get price {
    return Intl.message('Price (VND)', name: 'price', desc: '', args: []);
  }

  /// `Local Delivery Price for {regionName}`
  String localDeliveryPrice(Object regionName) {
    return Intl.message(
      'Local Delivery Price for $regionName',
      name: 'localDeliveryPrice',
      desc: '',
      args: [regionName],
    );
  }

  /// `Delivery Price from {fromRegionName} to {toRegionName}`
  String interRegionDeliveryPrice(Object fromRegionName, Object toRegionName) {
    return Intl.message(
      'Delivery Price from $fromRegionName to $toRegionName',
      name: 'interRegionDeliveryPrice',
      desc: '',
      args: [fromRegionName, toRegionName],
    );
  }

  /// `No price data available.`
  String get noPriceDataAvailable {
    return Intl.message(
      'No price data available.',
      name: 'noPriceDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `No network connection`
  String get noConnection {
    return Intl.message(
      'No network connection',
      name: 'noConnection',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Please check your network connection`
  String get checkConnection {
    return Intl.message(
      'Please check your network connection',
      name: 'checkConnection',
      desc: '',
      args: [],
    );
  }

  /// `Order ID`
  String get orderId {
    return Intl.message('Order ID', name: 'orderId', desc: '', args: []);
  }

  /// `Sender Name`
  String get senderName {
    return Intl.message('Sender Name', name: 'senderName', desc: '', args: []);
  }

  /// `Sender Phone`
  String get senderPhone {
    return Intl.message(
      'Sender Phone',
      name: 'senderPhone',
      desc: '',
      args: [],
    );
  }

  /// `Package Description`
  String get packageDescription {
    return Intl.message(
      'Package Description',
      name: 'packageDescription',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get required {
    return Intl.message(
      'This field is required',
      name: 'required',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Weight`
  String get estimatedWeight {
    return Intl.message(
      'Estimated Weight',
      name: 'estimatedWeight',
      desc: '',
      args: [],
    );
  }

  /// `Receiver Name`
  String get receiverName {
    return Intl.message(
      'Receiver Name',
      name: 'receiverName',
      desc: '',
      args: [],
    );
  }

  /// `Receiver Phone`
  String get receiverPhone {
    return Intl.message(
      'Receiver Phone',
      name: 'receiverPhone',
      desc: '',
      args: [],
    );
  }

  /// `Goods Type`
  String get goodsType {
    return Intl.message('Goods Type', name: 'goodsType', desc: '', args: []);
  }

  /// `Normal`
  String get normalGoods {
    return Intl.message('Normal', name: 'normalGoods', desc: '', args: []);
  }

  /// `High Value`
  String get highValueGoods {
    return Intl.message(
      'High Value',
      name: 'highValueGoods',
      desc: '',
      args: [],
    );
  }

  /// `Order Value (VND)`
  String get orderValue {
    return Intl.message(
      'Order Value (VND)',
      name: 'orderValue',
      desc: '',
      args: [],
    );
  }

  /// `Sender ID (CCCD)`
  String get senderCCCD {
    return Intl.message(
      'Sender ID (CCCD)',
      name: 'senderCCCD',
      desc: '',
      args: [],
    );
  }

  /// `For high-value items, a surcharge of 100,000 VND applies for insurance.`
  String get insuranceNote {
    return Intl.message(
      'For high-value items, a surcharge of 100,000 VND applies for insurance.',
      name: 'insuranceNote',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueLabel {
    return Intl.message('Continue', name: 'continueLabel', desc: '', args: []);
  }

  /// `Success`
  String get successTitle {
    return Intl.message('Success', name: 'successTitle', desc: '', args: []);
  }

  /// `Your order has been successfully created.`
  String get successMessage {
    return Intl.message(
      'Your order has been successfully created.',
      name: 'successMessage',
      desc: '',
      args: [],
    );
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Sender Pays`
  String get senderPays {
    return Intl.message('Sender Pays', name: 'senderPays', desc: '', args: []);
  }

  /// `Receiver Pays`
  String get receiverPays {
    return Intl.message(
      'Receiver Pays',
      name: 'receiverPays',
      desc: '',
      args: [],
    );
  }

  /// `COD`
  String get cod {
    return Intl.message('COD', name: 'cod', desc: '', args: []);
  }

  /// `Estimated Price`
  String get estimatedPrice {
    return Intl.message(
      'Estimated Price',
      name: 'estimatedPrice',
      desc: '',
      args: [],
    );
  }

  /// `Order created successfully!`
  String get orderCreated {
    return Intl.message(
      'Order created successfully!',
      name: 'orderCreated',
      desc: '',
      args: [],
    );
  }

  /// `Create Order`
  String get createOrder {
    return Intl.message(
      'Create Order',
      name: 'createOrder',
      desc: '',
      args: [],
    );
  }

  /// `Order Details`
  String get orderDetails {
    return Intl.message(
      'Order Details',
      name: 'orderDetails',
      desc: '',
      args: [],
    );
  }

  /// `From Region`
  String get fromRegion {
    return Intl.message('From Region', name: 'fromRegion', desc: '', args: []);
  }

  /// `To Region`
  String get toRegion {
    return Intl.message('To Region', name: 'toRegion', desc: '', args: []);
  }

  /// `Region`
  String get region {
    return Intl.message('Region', name: 'region', desc: '', args: []);
  }

  /// `Office`
  String get office {
    return Intl.message('Office', name: 'office', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email to reset password`
  String get enterYourEmail {
    return Intl.message(
      'Enter your email to reset password',
      name: 'enterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Send reset code`
  String get sendResetCode {
    return Intl.message(
      'Send reset code',
      name: 'sendResetCode',
      desc: '',
      args: [],
    );
  }

  /// `This email is not registered.`
  String get emailNotRegistered {
    return Intl.message(
      'This email is not registered.',
      name: 'emailNotRegistered',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send reset code. Please try again.`
  String get sendCodeError {
    return Intl.message(
      'Failed to send reset code. Please try again.',
      name: 'sendCodeError',
      desc: '',
      args: [],
    );
  }

  /// `Check your email for the reset code.`
  String get checkYourEmailForCode {
    return Intl.message(
      'Check your email for the reset code.',
      name: 'checkYourEmailForCode',
      desc: '',
      args: [],
    );
  }

  /// `Enter code`
  String get enterCode {
    return Intl.message('Enter code', name: 'enterCode', desc: '', args: []);
  }

  /// `Verify code`
  String get verifyCode {
    return Intl.message('Verify code', name: 'verifyCode', desc: '', args: []);
  }

  /// `Enter your new password`
  String get enterNewPassword {
    return Intl.message(
      'Enter your new password',
      name: 'enterNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match.`
  String get passwordNotMatch {
    return Intl.message(
      'Passwords do not match.',
      name: 'passwordNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Failed to reset password.`
  String get resetPasswordError {
    return Intl.message(
      'Failed to reset password.',
      name: 'resetPasswordError',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message('Success', name: 'success', desc: '', args: []);
  }

  /// `Please check your email and follow the instructions to reset your password.`
  String get checkEmailToReset {
    return Intl.message(
      'Please check your email and follow the instructions to reset your password.',
      name: 'checkEmailToReset',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
