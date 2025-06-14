import 'package:flutter/material.dart';

class CreateDeliveryScreen extends StatelessWidget {
  const CreateDeliveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tao don hang"),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Create Delivery Screen')),
    );
  }
}
