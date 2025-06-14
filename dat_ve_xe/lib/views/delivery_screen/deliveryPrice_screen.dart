import 'package:flutter/material.dart';

class DeliveryPriceScreen extends StatelessWidget {
  const DeliveryPriceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bang gia"),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Delivery Price Screen')),
    );
  }
}
