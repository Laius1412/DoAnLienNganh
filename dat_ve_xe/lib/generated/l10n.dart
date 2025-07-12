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

  /// ` Update successful! `
  String get updateSuccessful {
    return Intl.message(
      ' Update successful! ',
      name: 'updateSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Update failed!`
  String get updateFailed {
    return Intl.message(
      'Update failed!',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Birthday`
  String get birthday {
    return Intl.message('Birthday', name: 'birthday', desc: '', args: []);
  }

  /// `Select birthday`
  String get selectBirthday {
    return Intl.message(
      'Select birthday',
      name: 'selectBirthday',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// ` Current Ticket`
  String get ticketCurrent {
    return Intl.message(
      ' Current Ticket',
      name: 'ticketCurrent',
      desc: '',
      args: [],
    );
  }

  /// `Used ticket`
  String get ticketUsed {
    return Intl.message('Used ticket', name: 'ticketUsed', desc: '', args: []);
  }

  /// `Ticket Details`
  String get ticketDetail {
    return Intl.message(
      'Ticket Details',
      name: 'ticketDetail',
      desc: '',
      args: [],
    );
  }

  /// `Ticket ID`
  String get ticketId {
    return Intl.message('Ticket ID', name: 'ticketId', desc: '', args: []);
  }

  /// `Booker`
  String get ticketUser {
    return Intl.message('Booker', name: 'ticketUser', desc: '', args: []);
  }

  /// `Travel Date`
  String get ticketDate {
    return Intl.message('Travel Date', name: 'ticketDate', desc: '', args: []);
  }

  /// `Departure Time`
  String get ticketStartTime {
    return Intl.message(
      'Departure Time',
      name: 'ticketStartTime',
      desc: '',
      args: [],
    );
  }

  /// `License Plate`
  String get ticketPlate {
    return Intl.message(
      'License Plate',
      name: 'ticketPlate',
      desc: '',
      args: [],
    );
  }

  /// `Seats`
  String get ticketSeats {
    return Intl.message('Seats', name: 'ticketSeats', desc: '', args: []);
  }

  /// `Total Price`
  String get ticketTotal {
    return Intl.message('Total Price', name: 'ticketTotal', desc: '', args: []);
  }

  /// `Start Point`
  String get ticketStart {
    return Intl.message('Start Point', name: 'ticketStart', desc: '', args: []);
  }

  /// `End Point`
  String get ticketEnd {
    return Intl.message('End Point', name: 'ticketEnd', desc: '', args: []);
  }

  /// `Scan this QR code at the ticket gate`
  String get ticketQrGuide {
    return Intl.message(
      'Scan this QR code at the ticket gate',
      name: 'ticketQrGuide',
      desc: '',
      args: [],
    );
  }

  /// `Route`
  String get route {
    return Intl.message('Route', name: 'route', desc: '', args: []);
  }

  /// `No Ticket`
  String get noTicket {
    return Intl.message('No Ticket', name: 'noTicket', desc: '', args: []);
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Pending payment`
  String get pendingPayment {
    return Intl.message(
      'Pending payment',
      name: 'pendingPayment',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get confirmed {
    return Intl.message('Confirmed', name: 'confirmed', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `Ticket code`
  String get ticketCode {
    return Intl.message('Ticket code', name: 'ticketCode', desc: '', args: []);
  }

  /// `Most frequent route:`
  String get statMostRoute {
    return Intl.message(
      'Most frequent route:',
      name: 'statMostRoute',
      desc: '',
      args: [],
    );
  }

  /// `times`
  String get statMostRouteCount {
    return Intl.message(
      'times',
      name: 'statMostRouteCount',
      desc: '',
      args: [],
    );
  }

  /// `Total tickets`
  String get statTotalTicket {
    return Intl.message(
      'Total tickets',
      name: 'statTotalTicket',
      desc: '',
      args: [],
    );
  }

  /// `Total money`
  String get statTotalMoney {
    return Intl.message(
      'Total money',
      name: 'statTotalMoney',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get statConfirmed {
    return Intl.message('Confirmed', name: 'statConfirmed', desc: '', args: []);
  }

  /// `Pending`
  String get statPending {
    return Intl.message('Pending', name: 'statPending', desc: '', args: []);
  }

  /// `Cancelled`
  String get statCancelled {
    return Intl.message('Cancelled', name: 'statCancelled', desc: '', args: []);
  }

  /// `Ticket status chart`
  String get statPieTitle {
    return Intl.message(
      'Ticket status chart',
      name: 'statPieTitle',
      desc: '',
      args: [],
    );
  }

  /// `Monthly cost chart`
  String get statBarTitle {
    return Intl.message(
      'Monthly cost chart',
      name: 'statBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Monthly ticket count chart`
  String get statLineTitle {
    return Intl.message(
      'Monthly ticket count chart',
      name: 'statLineTitle',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get statNoData {
    return Intl.message('No data', name: 'statNoData', desc: '', args: []);
  }

  /// `This is a sample policy content. You can update this in the localization file.`
  String get policyContent {
    return Intl.message(
      'This is a sample policy content. You can update this in the localization file.',
      name: 'policyContent',
      desc: '',
      args: [],
    );
  }

  /// `🚀 FLASH TRAVEL – Ứng dụng đặt vé xe khách thông minh\n\nFLASH TRAVEL là nền tảng đặt vé xe khách hàng đầu, mang đến trải nghiệm di chuyển nhanh chóng, an toàn và tiện lợi cho hành khách khắp cả nước.\n\nVới sứ mệnh \"Mỗi chuyến đi là một trải nghiệm đẳng cấp\", FLASH TRAVEL kết nối hàng trăm nhà xe uy tín chỉ với vài thao tác chạm.\n\n🚌 Dòng xe hiện đại – Phù hợp mọi nhu cầu:...`
  String get aboutContent {
    return Intl.message(
      '🚀 FLASH TRAVEL – Ứng dụng đặt vé xe khách thông minh\n\nFLASH TRAVEL là nền tảng đặt vé xe khách hàng đầu, mang đến trải nghiệm di chuyển nhanh chóng, an toàn và tiện lợi cho hành khách khắp cả nước.\n\nVới sứ mệnh \\"Mỗi chuyến đi là một trải nghiệm đẳng cấp\\", FLASH TRAVEL kết nối hàng trăm nhà xe uy tín chỉ với vài thao tác chạm.\n\n🚌 Dòng xe hiện đại – Phù hợp mọi nhu cầu:...',
      name: 'aboutContent',
      desc: '',
      args: [],
    );
  }

  /// `Policies & Terms of Service`
  String get policyTitle {
    return Intl.message(
      'Policies & Terms of Service',
      name: 'policyTitle',
      desc: '',
      args: [],
    );
  }

  /// `1. Ticket Booking Policy`
  String get policy1Title {
    return Intl.message(
      '1. Ticket Booking Policy',
      name: 'policy1Title',
      desc: '',
      args: [],
    );
  }

  /// `• Customers can book tickets online via the FLASH TRAVEL app or official website.\n• Each ticket is valid for one passenger and one trip only.\n• After successful booking, the system will send the ticket code via email and/or SMS to the customer.\n• Please check your trip information, name, and phone number carefully before confirming the booking.\n• FLASH TRAVEL is not responsible if incorrect information provided by the customer leads to loss of benefits when boarding.`
  String get policy1Content {
    return Intl.message(
      '• Customers can book tickets online via the FLASH TRAVEL app or official website.\n• Each ticket is valid for one passenger and one trip only.\n• After successful booking, the system will send the ticket code via email and/or SMS to the customer.\n• Please check your trip information, name, and phone number carefully before confirming the booking.\n• FLASH TRAVEL is not responsible if incorrect information provided by the customer leads to loss of benefits when boarding.',
      name: 'policy1Content',
      desc: '',
      args: [],
    );
  }

  /// `2. Payment Policy`
  String get policy2Title {
    return Intl.message(
      '2. Payment Policy',
      name: 'policy2Title',
      desc: '',
      args: [],
    );
  }

  /// `• Multiple payment methods supported: e-wallets (Momo, ZaloPay), domestic ATM cards, international cards (Visa/MasterCard), bank transfer.\n• All payment transactions are encrypted and secured according to international standards.\n• FLASH TRAVEL commits not to store your card information on the system.\n• If payment fails, please check your balance, limit, or contact customer support.`
  String get policy2Content {
    return Intl.message(
      '• Multiple payment methods supported: e-wallets (Momo, ZaloPay), domestic ATM cards, international cards (Visa/MasterCard), bank transfer.\n• All payment transactions are encrypted and secured according to international standards.\n• FLASH TRAVEL commits not to store your card information on the system.\n• If payment fails, please check your balance, limit, or contact customer support.',
      name: 'policy2Content',
      desc: '',
      args: [],
    );
  }

  /// `3. Ticket Exchange/Refund Policy`
  String get policy3Title {
    return Intl.message(
      '3. Ticket Exchange/Refund Policy',
      name: 'policy3Title',
      desc: '',
      args: [],
    );
  }

  /// `• Customers are allowed to exchange or refund tickets before departure time according to the regulations of each partner bus company.\n• To exchange/refund, customers need to provide the ticket code and personal verification information.\n• Some bus companies may apply exchange/refund fees or limit the time for exchange/refund (e.g., only accept exchanges 24h before departure).\n• FLASH TRAVEL will clearly notify the fees and conditions before you confirm the operation.\n• The refund amount (if any) will be transferred to your account within 3-7 working days, depending on the original payment method.`
  String get policy3Content {
    return Intl.message(
      '• Customers are allowed to exchange or refund tickets before departure time according to the regulations of each partner bus company.\n• To exchange/refund, customers need to provide the ticket code and personal verification information.\n• Some bus companies may apply exchange/refund fees or limit the time for exchange/refund (e.g., only accept exchanges 24h before departure).\n• FLASH TRAVEL will clearly notify the fees and conditions before you confirm the operation.\n• The refund amount (if any) will be transferred to your account within 3-7 working days, depending on the original payment method.',
      name: 'policy3Content',
      desc: '',
      args: [],
    );
  }

  /// `4. Service Usage Regulations`
  String get policy4Title {
    return Intl.message(
      '4. Service Usage Regulations',
      name: 'policy4Title',
      desc: '',
      args: [],
    );
  }

  /// `• Customers commit to using the service for the right purpose, not violating the law or the regulations of the bus company.\n• It is strictly forbidden to buy, sell, or transfer tickets illegally or use fake information to book tickets.\n• FLASH TRAVEL reserves the right to refuse service, cancel tickets, or lock accounts if fraudulent, scam, or public disorderly behavior is detected.\n• Customers must comply with luggage regulations, boarding time, and safety instructions from the bus company.`
  String get policy4Content {
    return Intl.message(
      '• Customers commit to using the service for the right purpose, not violating the law or the regulations of the bus company.\n• It is strictly forbidden to buy, sell, or transfer tickets illegally or use fake information to book tickets.\n• FLASH TRAVEL reserves the right to refuse service, cancel tickets, or lock accounts if fraudulent, scam, or public disorderly behavior is detected.\n• Customers must comply with luggage regulations, boarding time, and safety instructions from the bus company.',
      name: 'policy4Content',
      desc: '',
      args: [],
    );
  }

  /// `5. Privacy Policy`
  String get policy5Title {
    return Intl.message(
      '5. Privacy Policy',
      name: 'policy5Title',
      desc: '',
      args: [],
    );
  }

  /// `• FLASH TRAVEL is committed to absolutely protecting customers' personal and transaction information.\n• Customer information is only used for ticket booking, customer care, and service quality improvement purposes.\n• Information will not be shared or disclosed to third parties without customer consent, except as required by authorities or law.\n• Customers have the right to request correction, update, or deletion of personal information at any time.`
  String get policy5Content {
    return Intl.message(
      '• FLASH TRAVEL is committed to absolutely protecting customers\' personal and transaction information.\n• Customer information is only used for ticket booking, customer care, and service quality improvement purposes.\n• Information will not be shared or disclosed to third parties without customer consent, except as required by authorities or law.\n• Customers have the right to request correction, update, or deletion of personal information at any time.',
      name: 'policy5Content',
      desc: '',
      args: [],
    );
  }

  /// `6. Customer Support`
  String get policy6Title {
    return Intl.message(
      '6. Customer Support',
      name: 'policy6Title',
      desc: '',
      args: [],
    );
  }

  /// `• FLASH TRAVEL's customer care team is always ready to support 24/7 via hotline, email, and online chat on the app and website.\n• Hotline: 1900 1234 (1,000đ/min)\n• Email: support@flashtravel.vn\n• All inquiries and complaints will be received and processed within 24 working hours.`
  String get policy6Content {
    return Intl.message(
      '• FLASH TRAVEL\'s customer care team is always ready to support 24/7 via hotline, email, and online chat on the app and website.\n• Hotline: 1900 1234 (1,000đ/min)\n• Email: support@flashtravel.vn\n• All inquiries and complaints will be received and processed within 24 working hours.',
      name: 'policy6Content',
      desc: '',
      args: [],
    );
  }

  /// `By using FLASH TRAVEL services, you acknowledge that you have read, understood, and agreed to the above policies and terms.`
  String get policyFooter {
    return Intl.message(
      'By using FLASH TRAVEL services, you acknowledge that you have read, understood, and agreed to the above policies and terms.',
      name: 'policyFooter',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get aboutTitle {
    return Intl.message('About', name: 'aboutTitle', desc: '', args: []);
  }

  /// `FLASH TRAVEL – Smart coach ticket booking solution`
  String get aboutHeadline {
    return Intl.message(
      'FLASH TRAVEL – Smart coach ticket booking solution',
      name: 'aboutHeadline',
      desc: '',
      args: [],
    );
  }

  /// `FLASH TRAVEL is a modern coach ticket booking app, connecting hundreds of quality bus operators nationwide. With the motto \"Fast – Safe – Convenient\", we are committed to providing the best ticket booking experience for users.`
  String get aboutIntro {
    return Intl.message(
      'FLASH TRAVEL is a modern coach ticket booking app, connecting hundreds of quality bus operators nationwide. With the motto \\"Fast – Safe – Convenient\\", we are committed to providing the best ticket booking experience for users.',
      name: 'aboutIntro',
      desc: '',
      args: [],
    );
  }

  /// `Outstanding services`
  String get aboutServiceTitle {
    return Intl.message(
      'Outstanding services',
      name: 'aboutServiceTitle',
      desc: '',
      args: [],
    );
  }

  /// `• Modern sleeper and limousine buses, fully equipped.\n• Door-to-door transfer service in many provinces.\n• Flexible ticket exchange and refund support.`
  String get aboutServiceContent {
    return Intl.message(
      '• Modern sleeper and limousine buses, fully equipped.\n• Door-to-door transfer service in many provinces.\n• Flexible ticket exchange and refund support.',
      name: 'aboutServiceContent',
      desc: '',
      args: [],
    );
  }

  /// `Smart features`
  String get aboutFeatureTitle {
    return Intl.message(
      'Smart features',
      name: 'aboutFeatureTitle',
      desc: '',
      args: [],
    );
  }

  /// `• Book tickets quickly in 3 steps.\n• Track journeys, save ticket history.\n• Daily promotions and notifications.`
  String get aboutFeatureContent {
    return Intl.message(
      '• Book tickets quickly in 3 steps.\n• Track journeys, save ticket history.\n• Daily promotions and notifications.',
      name: 'aboutFeatureContent',
      desc: '',
      args: [],
    );
  }

  /// `Why choose FLASH TRAVEL`
  String get aboutReasonTitle {
    return Intl.message(
      'Why choose FLASH TRAVEL',
      name: 'aboutReasonTitle',
      desc: '',
      args: [],
    );
  }

  /// `✓ Simple, friendly interface.\n✓ Multiple payment methods integrated.\n✓ 24/7 support hotline.\n✓ Transparent, clear ticket prices.`
  String get aboutReasonContent {
    return Intl.message(
      '✓ Simple, friendly interface.\n✓ Multiple payment methods integrated.\n✓ 24/7 support hotline.\n✓ Transparent, clear ticket prices.',
      name: 'aboutReasonContent',
      desc: '',
      args: [],
    );
  }

  /// `FLASH TRAVEL TRANSPORT AND TOURISM SERVICE CO., LTD`
  String get aboutCompany {
    return Intl.message(
      'FLASH TRAVEL TRANSPORT AND TOURISM SERVICE CO., LTD',
      name: 'aboutCompany',
      desc: '',
      args: [],
    );
  }

  /// `Company information`
  String get aboutCompanyInfoTitle {
    return Intl.message(
      'Company information',
      name: 'aboutCompanyInfoTitle',
      desc: '',
      args: [],
    );
  }

  /// `• FLASH TRAVEL Technology Co., Ltd\n• Tax code: 0101010101\n• Head office: 2nd Floor, C50 Building, Ha Dong District, Hanoi City\n• Email: support@flashtravel.vn\n• Ticket booking hotline: 1900 1234 (1,000đ/min)`
  String get aboutCompanyInfoContent {
    return Intl.message(
      '• FLASH TRAVEL Technology Co., Ltd\n• Tax code: 0101010101\n• Head office: 2nd Floor, C50 Building, Ha Dong District, Hanoi City\n• Email: support@flashtravel.vn\n• Ticket booking hotline: 1900 1234 (1,000đ/min)',
      name: 'aboutCompanyInfoContent',
      desc: '',
      args: [],
    );
  }

  /// `Mission & Vision`
  String get aboutMissionTitle {
    return Intl.message(
      'Mission & Vision',
      name: 'aboutMissionTitle',
      desc: '',
      args: [],
    );
  }

  /// `FLASH TRAVEL was born with the mission of modernizing the passenger transport industry in Vietnam, bringing customers a convenient, transparent and safest coach ticket booking experience. We constantly innovate to meet the increasing needs of users.\n\nVision\nTo become the leading coach ticket booking platform in Vietnam, connecting every journey, every region, contributing to the development of smart transportation.`
  String get aboutMissionContent {
    return Intl.message(
      'FLASH TRAVEL was born with the mission of modernizing the passenger transport industry in Vietnam, bringing customers a convenient, transparent and safest coach ticket booking experience. We constantly innovate to meet the increasing needs of users.\n\nVision\nTo become the leading coach ticket booking platform in Vietnam, connecting every journey, every region, contributing to the development of smart transportation.',
      name: 'aboutMissionContent',
      desc: '',
      args: [],
    );
  }

  /// `Core values`
  String get aboutCoreValueTitle {
    return Intl.message(
      'Core values',
      name: 'aboutCoreValueTitle',
      desc: '',
      args: [],
    );
  }

  /// `• Customer-centric: Always listen and serve wholeheartedly.\n• Innovation: Apply technology to improve service quality.\n• Transparency & Prestige: Commit to clear information, transparent ticket prices.\n• Cooperative development: Connect with many reputable bus operators nationwide.`
  String get aboutCoreValueContent {
    return Intl.message(
      '• Customer-centric: Always listen and serve wholeheartedly.\n• Innovation: Apply technology to improve service quality.\n• Transparency & Prestige: Commit to clear information, transparent ticket prices.\n• Cooperative development: Connect with many reputable bus operators nationwide.',
      name: 'aboutCoreValueContent',
      desc: '',
      args: [],
    );
  }

  /// `Follow us`
  String get aboutFollowTitle {
    return Intl.message(
      'Follow us',
      name: 'aboutFollowTitle',
      desc: '',
      args: [],
    );
  }

  /// `• Website: www.flashtravel.vn\n• Facebook: fb.com/flashtravel.vn\n• Zalo OA: FLASH TRAVEL\n• TikTok: @flashtravel.vn`
  String get aboutFollowContent {
    return Intl.message(
      '• Website: www.flashtravel.vn\n• Facebook: fb.com/flashtravel.vn\n• Zalo OA: FLASH TRAVEL\n• TikTok: @flashtravel.vn',
      name: 'aboutFollowContent',
      desc: '',
      args: [],
    );
  }

  /// `Ticket Management`
  String get ticketManagement {
    return Intl.message(
      'Ticket Management',
      name: 'ticketManagement',
      desc: '',
      args: [],
    );
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
