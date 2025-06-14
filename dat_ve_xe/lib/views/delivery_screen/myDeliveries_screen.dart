import 'package:flutter/material.dart';

class MyDeliveriesScreen extends StatelessWidget {
  const MyDeliveriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Don hang cua toi'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('My Deliveries Screen')),
    );
  }
}
