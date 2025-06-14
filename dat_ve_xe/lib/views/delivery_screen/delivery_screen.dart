import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dat_ve_xe/views/personal_screen/login_request_card.dart';
import 'dart:async';

class DeliveryScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  const DeliveryScreen({Key? key, required this.onLanguageChanged})
    : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Khi trạng thái đăng nhập thay đổi, gọi setState để rebuild widget
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const Center(
        child: Text('Trang Gửi Hàng khi đã đăng nhập'),
      ); // Thay thế bằng nội dung thực tế của trang gửi hàng
    } else {
      return Center(
        child: SizedBox(
          width: 400,
          child: LoginRequestCard(onLanguageChanged: widget.onLanguageChanged),
        ),
      );
    }
  }
}
