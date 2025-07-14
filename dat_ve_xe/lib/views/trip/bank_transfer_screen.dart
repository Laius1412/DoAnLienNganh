import 'package:flutter/material.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:dat_ve_xe/service/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class BankTransferScreen extends StatefulWidget {
  final String bookingId;
  final int totalAmount;

  const BankTransferScreen({
    Key? key,
    required this.bookingId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  final BookingService _bookingService = BookingService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isPaymentSuccessful = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển khoản ngân hàng'),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin tài khoản ngân hàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 243, 232),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color.fromARGB(255, 253, 109, 37),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin tài khoản ngân hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 253, 109, 37),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBankInfo(
                    'Ngân hàng:',
                    'BIDV',
                    Icons.account_balance,
                  ),
                  _buildBankInfo(
                    'Số tài khoản:',
                    '5121034942',
                    Icons.account_balance_wallet,
                  ),
                  _buildBankInfo(
                    'Chủ tài khoản:',
                    'Ngueyn Tran Viet Anh',
                    Icons.person,
                  ),
                  _buildBankInfo(
                    'Nội dung chuyển khoản:',
                    'Thanh toan ${widget.bookingId}',
                    Icons.description,
                  ),
                  _buildBankInfo(
                    'Số tiền:',
                    '${NumberFormat("#,###", "vi_VN").format(widget.totalAmount)}đ',
                    Icons.attach_money,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code (placeholder)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Mã QR chuyển khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 100,
                            color: Color.fromARGB(255, 253, 109, 37),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'QR Code',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload ảnh bill
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ảnh xác nhận chuyển khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImage != null) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Chọn ảnh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 253, 109, 37),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _selectedImage = null),
                            icon: const Icon(Icons.delete),
                            label: const Text('Xóa'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút thanh toán
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedImage != null && !_isLoading ? _handlePayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 253, 109, 37),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Xác nhận thanh toán',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 253, 109, 37), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ảnh xác nhận chuyển khoản')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      String? imageUrl;
      
      imageUrl = await CloudinaryService.uploadImage(
        _selectedImage!,
        'giap15', // Thay bằng upload preset thực tế
        'daturixq2', // Thay bằng cloud name thực tế
      );
      

      if (imageUrl == null) {
        throw Exception('Không thể upload ảnh. Vui lòng kiểm tra kết nối mạng và thử lại.');
      }

      // Cập nhật booking với ảnh và xác nhận thanh toán
      final success = await _bookingService.confirmPaymentWithImage(
        widget.bookingId,
        imageUrl,
      );

      if (success) {
        setState(() => _isPaymentSuccessful = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán thành công!')),
          );
          // Navigate back to home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thanh toán thất bại. Vui lòng thử lại!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 