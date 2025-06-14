import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dat_ve_xe/views/personal_screen/login_request_card.dart';

class MyTicketScreen extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  const MyTicketScreen({Key? key, required this.onLanguageChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const SizedBox.shrink();
    } else {
      return Center(
        child: SizedBox(
          width: 400,
          child: LoginRequestCard(onLanguageChanged: onLanguageChanged),
        ),
      );
    }
  }
}
