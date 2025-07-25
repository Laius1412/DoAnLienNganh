import 'package:flutter/material.dart';
import 'package:dat_ve_xe/server/booking_service.dart';
import 'package:dat_ve_xe/service/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final cardColor = isDark ? Colors.grey[900]! : const Color.fromARGB(255, 255, 243, 232);
    final borderColor = isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    final textColor = isDark ? Colors.white : Colors.black;
    final labelColor = (isDark ? Colors.orange[200] : const Color.fromARGB(255, 253, 109, 37))!;
    final subTextColor = (isDark ? Colors.white70 : Colors.grey)!;
    final qrBg = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    final qrInnerBg = isDark ? Colors.black : Colors.white;
    final qrBorder = isDark ? Colors.orange[900]! : Colors.grey[300]!;
    final buttonBg = isDark ? Colors.orange[900]! : const Color.fromARGB(255, 253, 109, 37);
    final buttonDeleteBg = isDark ? Colors.red[900]! : Colors.red;
    final buttonText = Colors.white;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bankTransferTitle, style: TextStyle(color: textColor)),
        backgroundColor: buttonBg,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: textColor),
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
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.bankInfoTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBankInfo(AppLocalizations.of(context)!.bankNameLabel, AppLocalizations.of(context)!.bankNameValue, Icons.account_balance, labelColor, subTextColor, textColor),
                  _buildBankInfo(AppLocalizations.of(context)!.accountNumberLabel, AppLocalizations.of(context)!.accountNumberValue, Icons.account_balance_wallet, labelColor, subTextColor, textColor),
                  _buildBankInfo(AppLocalizations.of(context)!.accountHolderLabel, AppLocalizations.of(context)!.accountHolderValue, Icons.person, labelColor, subTextColor, textColor),
                  _buildBankInfo(AppLocalizations.of(context)!.transferContentLabel, AppLocalizations.of(context)!.transferContentValue(widget.bookingId), Icons.description, labelColor, subTextColor, textColor),
                  _buildBankInfo(AppLocalizations.of(context)!.amountLabel, '${NumberFormat("#,###", "vi_VN").format(widget.totalAmount)}đ', Icons.attach_money, labelColor, subTextColor, textColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code (placeholder)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: qrBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.qrTransferTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: qrInnerBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: qrBorder),
                    ),
                    child: Center(
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
                            AppLocalizations.of(context)!.qrCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: subTextColor,
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
                color: qrBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.uploadBillTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImage != null) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: qrBorder),
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
                          label: Text(AppLocalizations.of(context)!.chooseImage),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBg,
                            foregroundColor: buttonText,
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
                            label: Text(AppLocalizations.of(context)!.delete),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonDeleteBg,
                              foregroundColor: buttonText,
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
                  backgroundColor: buttonBg,
                  foregroundColor: buttonText,
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
                    : Text(
                        AppLocalizations.of(context)!.confirmPayment,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo(String label, String value, IconData icon, Color labelColor, Color subTextColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: labelColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextColor,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
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
        SnackBar(content: Text(AppLocalizations.of(context)!.imagePickError(e.toString()))),
      );
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseChooseImage)),
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
        throw Exception(AppLocalizations.of(context)!.uploadImageError);
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
            SnackBar(content: Text(AppLocalizations.of(context)!.paymentSuccess)),
          );
          // Navigate back to home screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.paymentFailed)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 