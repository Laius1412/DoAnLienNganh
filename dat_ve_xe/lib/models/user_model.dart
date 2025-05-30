class UserModel {
  final String id;
  final String avt;
  final DateTime birth;
  final String email;
  final String fcmToken;
  final String gender;
  final String name;
  final String phone;
  final String role;

  UserModel({
    required this.id,
    required this.avt,
    required this.birth,
    required this.email,
    required this.fcmToken,
    required this.gender,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      avt: data['avt'] ?? '',
      birth: DateTime.parse(data['birth']),
      email: data['email'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
      gender: data['gender'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avt': avt,
      'birth': birth.toIso8601String(),
      'email': email,
      'fcmToken': fcmToken,
      'gender': gender,
      'name': name,
      'phone': phone,
      'role': role,
    };
  }
}
