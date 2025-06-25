// File: lib/views/delivery_screen/detailsOrders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/widgets/success_overlay.dart';
import 'package:dat_ve_xe/views/delivery_screen/delivery_screen.dart';

class DetailsOrdersScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const DetailsOrdersScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.orderDetails)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildRow(loc.orderId, order['id']),
                _buildRow(loc.senderName, order['nameFrom']),
                _buildRow(loc.senderPhone, order['phoneFrom']),
                _buildRow(loc.receiverName, order['nameTo']),
                _buildRow(loc.receiverPhone, order['phoneTo']),
                _buildRow(loc.packageDescription, order['details']),
                _buildRow(loc.estimatedWeight, "${order['mass']} kg"),
                _buildRow(
                  loc.goodsType,
                  order['type'] == 'highvalue'
                      ? loc.highValueGoods
                      : loc.normalGoods,
                ),
                if (order['type'] == 'highvalue')
                  _buildRow(loc.orderValue, "${order['orderValue']} VND"),
                if (order['type'] == 'highvalue')
                  _buildRow(loc.senderCCCD, order['cccd']),
                _buildRow(
                  loc.paymentMethod,
                  order['typePayment'] == 'postPayment'
                      ? loc.senderPays
                      : loc.receiverPays,
                ),
                _buildRow(loc.cod, "${order['cod']} VND"),
                _buildRow(loc.estimatedPrice, "${order['price']} VND"),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (_) => SuccessOverlay(
                            message: loc.orderCreated,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => DeliveryScreen(
                                        onLanguageChanged: (Locale) {},
                                      ),
                                ),
                              );
                            },
                          ),
                    );
                  },
                  child: Text(loc.createOrder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text("$label:")),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
