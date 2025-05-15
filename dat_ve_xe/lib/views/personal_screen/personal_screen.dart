import 'package:dat_ve_xe/views/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  bool isLoggedIn = false;

  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String userName = 'Nguyễn Văn A'; // Giả lập tên người dùng
  String avatarUrl = 'https://via.placeholder.com/100'; // Ảnh đại diện mẫu

  void _login() {
    // Giả lập đăng nhập
    setState(() {
      isLoggedIn = true;
    });
  }

  void _logout() {
    setState(() {
      isLoggedIn = false;
      _emailPhoneController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        actions:
            isLoggedIn
                ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
                ]
                : [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            isLoggedIn ? _buildUserProfile() : _buildLoginForm(),
            const SizedBox(height: 30),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Cài đặt',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.policy,
              title: 'Chính sách',
              onTap: () {
                Navigator.pushNamed(context, '/policy');
              },
            ),
            _buildMenuItem(
              icon: Icons.info,
              title: 'Giới thiệu',
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailPhoneController,
          decoration: const InputDecoration(
            labelText: 'Email hoặc Số điện thoại',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: const Text('Quên mật khẩu?'),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _login,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.orange, width: 2), // Viền cam
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            backgroundColor: const Color.fromARGB(255, 251, 215, 161),
          ),
          child: const Center(
            child: Text(
              'Đăng nhập',
              style: TextStyle(color: Color.fromARGB(255, 3, 74, 253)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Chưa có tài khoản?'),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Đăng ký'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Column(
      children: [
        CircleAvatar(radius: 50, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(height: 12),
        Text(
          userName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/edit-profile');
          },
          child: const Text('Chỉnh sửa thông tin cá nhân'),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orange, width: 2), // Viền cam
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange), // Đổi màu icon nếu muốn
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.orange,
        ), // Đổi màu mũi tên nếu muốn
        onTap: onTap,
      ),
    );
  }
}
