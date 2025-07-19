import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/service/delivery_firestore_service.dart';
import 'package:dat_ve_xe/service/auth_service.dart';
import 'package:dat_ve_xe/views/delivery_screen/detailsOrders_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _nameToController = TextEditingController();
  final _phoneToController = TextEditingController();
  final _cccdController = TextEditingController();
  final _orderValueController = TextEditingController();
  final _codController = TextEditingController();
  final _massController = TextEditingController();

  double _mass = 1.0;
  String _type = 'normal';
  String _typePayment = 'postPayment';
  String? _fromRegion;
  String? _fromOffice;
  String? _toRegion;
  String? _toOffice;

  String? _orderId;
  String? _senderName;
  String? _senderPhone;

  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _offices = [];
  bool _loadingRegions = true;
  bool _loadingOffices = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
    _massController.text = _mass.toStringAsFixed(1);
    _fetchRegionsAndOffices();
  }

  Future<void> _initializeUserInfo() async {
    final user = await AuthService.getCurrentUser();
    final now = DateTime.now();
    final phone = user.phone;
    final id =
        'FT${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year}${now.hour}${now.minute}${now.second}${phone.substring(phone.length - 4)}';

    setState(() {
      _orderId = id;
      _senderName = user.name;
      _senderPhone = phone;
    });
  }

  Future<void> _fetchRegionsAndOffices() async {
    final regionsSnap =
        await FirebaseFirestore.instance.collection('regions').get();
    final officesSnap =
        await FirebaseFirestore.instance.collection('offices').get();

    if (!mounted) return;

    setState(() {
      _regions =
          regionsSnap.docs
              .map(
                (e) => {
                  'id': e['regionId'], // sửa lại từ Firestore field
                  'name': e['regionName'],
                },
              )
              .toList();

      _offices =
          officesSnap.docs
              .map(
                (e) => {
                  'officeId': e['officeId'], // dùng officeId cho đồng nhất
                  'officeName': e['officeName'],
                  'address': e['address'],
                  'regionId': e['regionId'],
                },
              )
              .toList();

      _loadingRegions = false;
      _loadingOffices = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameToController.dispose();
    _phoneToController.dispose();
    _cccdController.dispose();
    _orderValueController.dispose();
    _codController.dispose();
    _massController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Đảm bảo loading tối thiểu 3 giây
    final start = DateTime.now();

    if (_fromRegion == null ||
        _fromOffice == null ||
        _toRegion == null ||
        _toOffice == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn đầy đủ nơi gửi và nơi nhận!')),
      );
      return;
    }

    if (_fromOffice == _toOffice) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Văn phòng gửi và nhận không được trùng nhau!')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy tài khoản đăng nhập!')),
      );
      return;
    }

    final price = await DeliveryFirestoreService.estimatePrice(
      _fromRegion!,
      _toRegion!,
      _mass,
      _type == 'highvalue',
    );

    final order = {
      'id': _orderId,
      'userId': userId,
      'nameFrom': _senderName,
      'phoneFrom': _senderPhone,
      'details': _descriptionController.text,
      'mass': _mass,
      'nameTo': _nameToController.text,
      'phoneTo': _phoneToController.text,
      'type': _type,
      'cccd': _type == 'highvalue' ? _cccdController.text : '',
      'orderValue': _type == 'highvalue' ? _orderValueController.text : '',
      'fromRegionId': _fromRegion,
      'toRegionId': _toRegion,
      'fromOfficeId': _fromOffice,
      'toOfficeId': _toOffice,
      'price': price,
      'typePayment': _typePayment,
      'cod': _codController.text,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Không showDialog nữa, chỉ dùng _isLoading để hiển thị overlay
    // await DeliveryFirestoreService.createDelivery(order); // Nếu muốn gửi ở đây thì giữ lại, nếu không thì bỏ

    // Đợi cho đủ 3 giây nếu xử lý quá nhanh
    final elapsed = DateTime.now().difference(start);
    if (elapsed.inMilliseconds < 3000) {
      await Future.delayed(
        Duration(milliseconds: 3000 - elapsed.inMilliseconds),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailsOrdersScreen(order: order)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.createDelivery)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoField(loc.orderId, _orderId),
                  _infoField(loc.senderName, _senderName),
                  _infoField(loc.senderPhone, _senderPhone),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: loc.packageDescription,
                    ),
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? loc.required : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.estimatedWeight,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Slider(
                      min: 0.1,
                      max: 100.0,
                      divisions: 999,
                      value: _mass,
                      label: _mass.toStringAsFixed(1),
                      onChanged: (val) {
                        setState(() {
                          // Làm tròn về đúng bước 0.1
                          _mass = double.parse(val.toStringAsFixed(1));
                          _massController.text = _mass.toStringAsFixed(1);
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _massController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      suffixText: 'kg',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val.replaceAll(',', '.'));
                      if (parsed != null && parsed > 0) {
                        setState(() {
                          _mass = parsed.clamp(0.1, 100.0);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameToController,
                    decoration: InputDecoration(labelText: loc.receiverName),
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? loc.required : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneToController,
                    maxLength: 10,
                    decoration: InputDecoration(labelText: loc.receiverPhone),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator:
                        (val) =>
                            val == null || val.isEmpty ? loc.required : null,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    loc.goodsType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'normal',
                        groupValue: _type,
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                      Text(loc.normalGoods),
                      Radio<String>(
                        value: 'highvalue',
                        groupValue: _type,
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                      Text(loc.highValueGoods),
                    ],
                  ),
                  if (_type == 'highvalue') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderValueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: loc.orderValue),
                      validator: (val) {
                        if (_type == 'highvalue' &&
                            (val == null || val.isEmpty)) {
                          return loc.required;
                        }
                        if (_type == 'highvalue' &&
                            int.tryParse(val!) == null) {
                          return 'Chỉ nhập số';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cccdController,
                      maxLength: 12,
                      decoration: InputDecoration(labelText: loc.senderCCCD),
                      validator: (val) {
                        if (_type == 'highvalue' &&
                            (val == null || val.isEmpty)) {
                          return loc.required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        loc.insuranceNote,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // =================== NƠI GỬI ===================
                  Text(
                    loc.fromRegion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Khu vực gửi
                  _loadingRegions
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                        value: _fromRegion,
                        items:
                            _regions
                                .where(
                                  (region) =>
                                      region['id'] != null &&
                                      region['name'] != null,
                                )
                                .map(
                                  (region) => DropdownMenuItem<String>(
                                    value: region['id'].toString(),
                                    child: Text(region['name'].toString()),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() {
                              _fromRegion = val;
                              _fromOffice = null;
                            }),
                        decoration: InputDecoration(labelText: loc.region),
                      ),

                  const SizedBox(height: 12),

                  // Văn phòng gửi
                  _loadingOffices
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                        value:
                            _offices.any(
                                  (o) =>
                                      o['regionId'] == _fromRegion &&
                                      o['officeId'] == _fromOffice,
                                )
                                ? _fromOffice
                                : null,
                        items:
                            (_fromRegion == null || _offices.isEmpty)
                                ? []
                                : _offices
                                    .where(
                                      (office) =>
                                          office['regionId'] == _fromRegion &&
                                          office['officeName'] != null &&
                                          office['address'] != null &&
                                          office['officeId'] != _toOffice,
                                    )
                                    .map(
                                      (office) => DropdownMenuItem<String>(
                                        value: office['officeId'],
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${office['officeName']} (${office['address']})',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                        selectedItemBuilder: (context) {
                          final filtered =
                              (_fromRegion == null || _offices.isEmpty)
                                  ? []
                                  : _offices
                                      .where(
                                        (office) =>
                                            office['regionId'] == _fromRegion &&
                                            office['officeName'] != null &&
                                            office['address'] != null &&
                                            office['officeId'] != _toOffice,
                                      )
                                      .toList();
                          return filtered
                              .map(
                                (office) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    office['officeName'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList();
                        },
                        onChanged: (val) => setState(() => _fromOffice = val),
                        decoration: InputDecoration(
                          labelText: loc.office,
                          hintText: 'Chọn một mục',
                        ),
                      ),

                  const SizedBox(height: 20),

                  // =================== NƠI NHẬN ===================
                  Text(
                    loc.toRegion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Khu vực nhận
                  _loadingRegions
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                        value: _toRegion,
                        items:
                            _regions
                                .where(
                                  (region) =>
                                      region['id'] != null &&
                                      region['name'] != null,
                                )
                                .map(
                                  (region) => DropdownMenuItem<String>(
                                    value: region['id'].toString(),
                                    child: Text(region['name'].toString()),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() {
                              _toRegion = val;
                              _toOffice = null;
                            }),
                        decoration: InputDecoration(labelText: loc.region),
                      ),

                  const SizedBox(height: 12),

                  // Văn phòng nhận
                  _loadingOffices
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                        value:
                            _offices.any(
                                  (o) =>
                                      o['regionId'] == _toRegion &&
                                      o['officeId'] == _toOffice,
                                )
                                ? _toOffice
                                : null,
                        items:
                            (_toRegion == null || _offices.isEmpty)
                                ? []
                                : _offices
                                    .where(
                                      (office) =>
                                          office['regionId'] == _toRegion &&
                                          office['officeName'] != null &&
                                          office['address'] != null &&
                                          office['officeId'] != _fromOffice,
                                    )
                                    .map(
                                      (office) => DropdownMenuItem<String>(
                                        value: office['officeId'],
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${office['officeName']} (${office['address']})',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                        selectedItemBuilder: (context) {
                          final filtered =
                              (_toRegion == null || _offices.isEmpty)
                                  ? []
                                  : _offices
                                      .where(
                                        (office) =>
                                            office['regionId'] == _toRegion &&
                                            office['officeName'] != null &&
                                            office['address'] != null &&
                                            office['officeId'] != _fromOffice,
                                      )
                                      .toList();
                          return filtered
                              .map(
                                (office) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    office['officeName'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList();
                        },
                        onChanged: (val) => setState(() => _toOffice = val),
                        decoration: InputDecoration(
                          labelText: loc.office,
                          hintText: 'Chọn một mục',
                        ),
                      ),

                  const SizedBox(height: 20),

                  Text(
                    loc.paymentMethod,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'postPayment', // Người gửi trả
                        groupValue: _typePayment,
                        onChanged: (val) => setState(() => _typePayment = val!),
                      ),
                      Text(loc.senderPays),
                      Radio<String>(
                        value: 'recievePayment', // Người nhận trả
                        groupValue: _typePayment,
                        onChanged: (val) => setState(() => _typePayment = val!),
                      ),
                      Text(loc.receiverPays),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: loc.cod,
                      suffixText: 'VND',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        final parsed = int.tryParse(val);
                        if (parsed == null || parsed < 0)
                          return 'Số tiền không hợp lệ';
                      }
                      // Nếu để trống thì hợp lệ
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        (_fromRegion == null ||
                                _fromOffice == null ||
                                _toRegion == null ||
                                _toOffice == null)
                            ? null
                            : _submit,
                    child: Text(loc.continueLabel),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.orange,
                    size: 30,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value ?? '', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
