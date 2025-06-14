import 'package:flutter/material.dart';

class TrackDeliveryScreen extends StatelessWidget {
  const TrackDeliveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tra cuu don hang"),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Track Delivery Screen')),
    );
  }
}
