import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_ve_xe/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  Future<bool> updateUser(String userId, {
    required String name,
    required DateTime birth,
    required String gender,
    String? avt,
  }) async {
    try {
      final data = {
        'name': name,
        'birth': birth.toIso8601String(),
        'gender': gender,
      };
      if (avt != null) data['avt'] = avt;
      await _firestore.collection('users').doc(userId).update(data);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
}
