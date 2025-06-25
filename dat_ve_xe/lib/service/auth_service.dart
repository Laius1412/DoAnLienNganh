import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Trả về thông tin người dùng hiện tại từ Firestore
  static Future<UserData> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      throw Exception('User not found in Firestore');
    }

    final data = doc.data()!;
    return UserData(
      uid: user.uid,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

/// Lớp dữ liệu người dùng (tùy bạn điều chỉnh thêm nếu cần)
class UserData {
  final String uid;
  final String name;
  final String phone;

  UserData({required this.uid, required this.name, required this.phone});
}
