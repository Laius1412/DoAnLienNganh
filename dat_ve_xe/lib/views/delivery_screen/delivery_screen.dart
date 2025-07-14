import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dat_ve_xe/views/personal_screen/login_request_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:dat_ve_xe/views/delivery_screen/createDelivery_screen.dart';
import 'package:dat_ve_xe/views/delivery_screen/deliveryPrice_screen.dart';
import 'package:dat_ve_xe/views/delivery_screen/myDeliveries_screen.dart';
import 'package:dat_ve_xe/views/delivery_screen/trackDelivery_screen.dart';

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

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: Color.fromARGB(255, 253, 109, 37),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final t = AppLocalizations.of(context)!;

    if (user != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildMenuCard(
                context,
                t.deliveryPrice,
                Icons.price_change,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryPriceScreen(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                t.createDelivery,
                Icons.add_box,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDeliveryScreen(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                t.trackDelivery,
                Icons.search,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrackDeliveryScreen(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                t.myDeliveries,
                Icons.local_shipping,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MyDeliveriesScreen(
                          onLanguageChanged: widget.onLanguageChanged,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
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
