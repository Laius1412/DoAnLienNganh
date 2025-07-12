import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/models/delivery_models.dart';
import 'package:dat_ve_xe/views/personal_screen/login_request_card.dart';

class MyDeliveriesScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const MyDeliveriesScreen({Key? key, required this.onLanguageChanged})
    : super(key: key);

  @override
  State<MyDeliveriesScreen> createState() => _MyDeliveriesScreenState();
}

class _MyDeliveriesScreenState extends State<MyDeliveriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DeliveryOrder> _deliveries = [];
  bool _isLoading = true;
  User? _currentUser;
  Map<String, String> _regionNames = {};

  @override
  void initState() {
    super.initState();
    _fetchRegionNames();
    _auth.authStateChanges().listen((user) {
      if (user != null && user.uid != _currentUser?.uid) {
        _currentUser = user;
        _loadDeliveries();
      } else if (user == null) {
        setState(() {
          _currentUser = null;
          _deliveries = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchRegionNames() async {
    try {
      final regionSnapshot = await _firestore.collection('regions').get();
      _regionNames = {
        for (var doc in regionSnapshot.docs)
          doc.id: Region.fromFirestore(doc).regionName,
      };
    } catch (e) {
      print('Error fetching region names: $e');
    }
  }

  Future<void> _loadDeliveries() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('Current user uid: ${_currentUser!.uid}');

      // Thử truy vấn không có orderBy trước
      final querySnapshot =
          await _firestore
              .collection('deliveryOrders')
              .where('userId', isEqualTo: _currentUser!.uid)
              .get();

      print(
        'Found ${querySnapshot.docs.length} orders for user ${_currentUser!.uid}',
      );

      // In ra thông tin từng document để debug
      for (var doc in querySnapshot.docs) {
        print('Order id: ${doc.id}');
        print('  userId: ${doc.data()['userId']}');
        print('  createdAt: ${doc.data()['createdAt']}');
        print('  status: ${doc.data()['status']}');
      }

      final deliveries = <DeliveryOrder>[];
      for (var doc in querySnapshot.docs) {
        try {
          final delivery = DeliveryOrder.fromFirestore(doc);
          deliveries.add(delivery);
          print('Successfully parsed delivery: ${delivery.id}');
        } catch (e) {
          print('Error parsing delivery ${doc.id}: $e');
        }
      }

      setState(() {
        _deliveries = deliveries;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading deliveries: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'accepted':
        return Colors.indigo;
      case 'delivering':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'returning':
        return Colors.red;
      case 'returned':
        return Colors.red[700]!;
      case 'received':
        return Colors.green[700]!;
      case 'refused':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getRegionName(String regionId) {
    return _regionNames[regionId] ?? regionId;
  }

  String _getGoodsTypeText(String type) {
    switch (type) {
      case 'highvalue':
        return 'Hàng giá trị cao';
      case 'normal':
        return 'Hàng thường';
      default:
        return type;
    }
  }

  String _getPaymentMethodText(String typePayment) {
    switch (typePayment) {
      case 'postPayment':
        return 'Người gửi thanh toán';
      case 'recievePayment':
        return 'Người nhận thanh toán';
      default:
        return typePayment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.myDeliveries),
          backgroundColor: const Color.fromARGB(255, 253, 109, 37),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: SizedBox(
            width: 400,
            child: LoginRequestCard(
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.myDeliveries),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _deliveries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadDeliveries,
                child: _buildDeliveriesList(),
              ),
    );
  }

  Widget _buildEmptyState() {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            t.noDeliveries,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.noDeliveriesMessage,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveriesList() {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
        final delivery = _deliveries[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với ID và Status
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: const Color.fromARGB(255, 253, 109, 37),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        delivery.id,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          delivery.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _getStatusColor(delivery.status),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        delivery.getStatusText(
                          Localizations.localeOf(context).languageCode,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(delivery.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Thông tin người gửi
                _buildInfoSection('Thông tin người gửi', [
                  _buildInfoRow('Tên người gửi', delivery.nameFrom),
                  _buildInfoRow('Số điện thoại', delivery.phoneFrom),
                  if (delivery.cccd.isNotEmpty)
                    _buildInfoRow('CCCD', delivery.cccd),
                ], isDark),

                const Divider(),

                // Thông tin người nhận
                _buildInfoSection('Thông tin người nhận', [
                  _buildInfoRow('Tên người nhận', delivery.nameTo),
                  _buildInfoRow('Số điện thoại', delivery.phoneTo),
                ], isDark),

                const Divider(),

                // Thông tin kiện hàng
                _buildInfoSection('Thông tin kiện hàng', [
                  _buildInfoRow('Mô tả kiện hàng', delivery.details),
                  _buildInfoRow('Khối lượng', '${delivery.mass} kg'),
                  _buildInfoRow('Loại hàng', _getGoodsTypeText(delivery.type)),
                  _buildInfoRow(
                    'Giá trị đơn hàng',
                    '${delivery.orderValue} VND',
                  ),
                  _buildInfoRow(
                    'Giá cước',
                    '${delivery.price.toStringAsFixed(0)} VND',
                  ),
                ], isDark),

                const Divider(),

                // Thông tin tuyến đường
                _buildInfoSection('Thông tin tuyến đường', [
                  _buildInfoRow(
                    'Nơi gửi',
                    _getRegionName(delivery.fromRegionId),
                  ),
                  _buildInfoRow(
                    'Nơi nhận',
                    _getRegionName(delivery.toRegionId),
                  ),
                ], isDark),

                const Divider(),

                // Thông tin thanh toán
                _buildInfoSection('Thông tin thanh toán', [
                  _buildInfoRow(
                    'Phương thức thanh toán',
                    _getPaymentMethodText(delivery.typePayment),
                  ),
                  if (delivery.cod.isNotEmpty)
                    _buildInfoRow('COD', delivery.cod),
                ], isDark),

                const Divider(),

                // Thông tin thời gian
                _buildInfoSection('Thông tin thời gian', [
                  _buildInfoRow(
                    'Ngày tạo',
                    _formatDateTime(delivery.createdAt),
                  ),
                  if (delivery.updatedAt != null)
                    _buildInfoRow(
                      'Cập nhật lần cuối',
                      _formatDateTime(delivery.updatedAt!),
                    ),
                ], isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
