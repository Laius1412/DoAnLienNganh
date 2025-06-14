import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/widgets/price_table_widget.dart';
import 'package:dat_ve_xe/models/delivery_models.dart';

class DeliveryPriceScreen extends StatefulWidget {
  const DeliveryPriceScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryPriceScreen> createState() => _DeliveryPriceScreenState();
}

class _DeliveryPriceScreenState extends State<DeliveryPriceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> _regionNames = {};
  List<PriceDelivery> _priceData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPriceData();
  }

  Future<void> _fetchPriceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch regions first
      final regionSnapshot = await _firestore.collection('regions').get();
      _regionNames = {
        for (var doc in regionSnapshot.docs)
          doc.id: Region.fromFirestore(doc).regionName,
      };

      // Fetch price delivery data
      final priceSnapshot = await _firestore.collection('priceDelivery').get();
      _priceData =
          priceSnapshot.docs
              .map((doc) => PriceDelivery.fromFirestore(doc))
              .toList();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      print('Error fetching price data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRegionName(String regionId) {
    return _regionNames[regionId] ??
        regionId; // Fallback to ID if name not found
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.deliveryPrice),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _priceData.isEmpty
              ? Center(child: Text(t.noPriceDataAvailable))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _priceData.length,
                        itemBuilder: (context, index) {
                          final priceEntry = _priceData[index];
                          final fromRegionName = _getRegionName(
                            priceEntry.fromRegionId,
                          );
                          final toRegionName = _getRegionName(
                            priceEntry.toRegionId,
                          );

                          String title;
                          if (priceEntry.fromRegionId ==
                              priceEntry.toRegionId) {
                            title = t.localDeliveryPrice(fromRegionName);
                          } else {
                            title = t.interRegionDeliveryPrice(
                              fromRegionName,
                              toRegionName,
                            );
                          }

                          return PriceTableWidget(
                            title: title,
                            weightRanges: priceEntry.weightRanges,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Lưu ý về điều khoản chuyển phát:', // Hardcoded Vietnamese
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Không nhận chuyển phát với đơn hàng quá 100kg.', // Hardcoded Vietnamese
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            '2. Với những đơn giá trị cao (>2 triệu đồng) và thiết bị điện tử yêu cầu giấy tờ đi kèm và căn cước công dân.', // Hardcoded Vietnamese
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            '3. Chúng tôi sẽ kiểm tra hàng kỹ và đóng gói cho khách hàng.', // Hardcoded Vietnamese
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            '4. Xác định tình trạng đơn hàng trước khi người vận chuyển tiếp nhận.', // Hardcoded Vietnamese
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
