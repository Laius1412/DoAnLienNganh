import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  /// Upload ảnh lên Cloudinary, trả về link ảnh nếu thành công, null nếu thất bại
  static Future<String?> uploadImage(File imageFile, String uploadPreset, String cloudName) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      return data['secure_url'] as String?;
    } else {
      return null;
    }
  }
} 