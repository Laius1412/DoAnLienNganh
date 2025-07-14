import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/models/delivery_models.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TrackDeliveryScreen extends StatefulWidget {
  const TrackDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<TrackDeliveryScreen> createState() => _TrackDeliveryScreenState();
}

class _TrackDeliveryScreenState extends State<TrackDeliveryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DeliveryOrder? _deliveryOrder;
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchDeliveryOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _deliveryOrder = null;
      _hasSearched = true;
    });

    // Đảm bảo loading tối thiểu 3 giây
    final start = DateTime.now();

    try {
      final lastFourDigits = _phoneController.text.trim();
      // Lấy tối đa 30 đơn hàng gần nhất (có thể tăng nếu cần)
      final querySnapshot =
          await _firestore
              .collection('deliveryOrders')
              .orderBy('createdAt', descending: true)
              .limit(30)
              .get();

      final docs =
          querySnapshot.docs.where((doc) {
            final phone = doc.data()['phoneTo']?.toString() ?? '';
            return phone.endsWith(lastFourDigits);
          }).toList();

      // Tính thời gian đã trôi qua
      final elapsed = DateTime.now().difference(start);
      final remaining = const Duration(seconds: 3) - elapsed;

      // Nếu chưa đủ 3 giây thì đợi thêm
      if (remaining.inMilliseconds > 0) {
        await Future.delayed(remaining);
      }

      if (docs.isNotEmpty) {
        setState(() {
          _deliveryOrder = DeliveryOrder.fromFirestore(docs.first);
        });
      } else {
        _showOrderNotFoundDialog();
      }
    } catch (e) {
      print('Error searching delivery order: $e');
      _showOrderNotFoundDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOrderNotFoundDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.orderNotFound),
          content: Text(t.orderNotFoundMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.ok),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.trackDelivery),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Box
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(255, 253, 109, 37),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: InputDecoration(
                              labelText: t.enterLastFourDigits,
                              border: InputBorder.none,
                              counterText: '',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return t.required;
                              }
                              if (value.length != 4) {
                                return 'Vui lòng nhập đúng 4 số cuối';
                              }
                              if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                                return 'Chỉ được nhập số';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _searchDeliveryOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                253,
                                109,
                                37,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 12.0,
                              ),
                            ),
                            child: Text(t.search),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Results Section
                if (_hasSearched && !_isLoading)
                  Expanded(
                    child:
                        _deliveryOrder != null
                            ? _buildOrderDetails()
                            : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.orange,
                    size: 60,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    final t = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = _deliveryOrder!;

    return Center(
      child: Container(
        width: 400,
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: const Color.fromARGB(255, 253, 109, 37),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.orderInformation,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(t.deliveryOrderId, order.id),
              _buildInfoRow(
                t.orderStatus,
                order.getStatusText(
                  Localizations.localeOf(context).languageCode,
                ),
                valueColor: _getStatusColor(order.status),
              ),
              _buildInfoRow(t.dateSend, _formatDateTime(order.createdAt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: valueColor ?? (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
