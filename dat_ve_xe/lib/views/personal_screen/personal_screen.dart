import 'package:dat_ve_xe/views/auth/login_screen.dart';
import 'package:dat_ve_xe/views/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_ve_xe/views/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class PersonalScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;

  const PersonalScreen({super.key, required this.onLanguageChanged});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userName;
  String? _avatarUrl;
  bool _isLoading = true;
  bool _isLoginSuccess = false;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (mounted) {
        _loadUserData();
      }
    });
    _loadUserData();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _userName = doc.data()?['name'] ?? 'Chưa cập nhật tên';
            _avatarUrl = doc.data()?['avt'];
          });
        } else {
          setState(() {
            _userName = 'Người dùng mới';
            _avatarUrl = null;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
        setState(() {
          _userName = 'Lỗi tải dữ liệu';
          _avatarUrl = null;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _userName = null;
        _avatarUrl = null;
        _isLoading = false;
      });
    }
  }

  void setLoginSuccess(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoginSuccess', value);
    setState(() {
      _isLoginSuccess = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(t.account),
      //   actions:
      //       isLoggedIn
      //           ? [
      //             IconButton(
      //               icon: const Icon(Icons.logout),
      //               onPressed: _logout,
      //             ),
      //           ]
      //           : [],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_auth.currentUser != null)
              _buildUserProfile()
            else
              _buildLoginButton(),
            const SizedBox(height: 30),
            _buildMenuItem(
              icon: Icons.settings,
              title: t.settings,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SettingsScreen(
                          onLanguageChanged: widget.onLanguageChanged,
                        ),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.policy,
              title: t.policy,
              onTap: () {
                Navigator.pushNamed(context, '/policy');
              },
            ),
            _buildMenuItem(
              icon: Icons.info,
              title: t.aboutUs,
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final t = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              t.pleaseLogin,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LoginScreen(
                          onLanguageChanged: widget.onLanguageChanged,
                          onLoginSuccess: () {
                            // Không cần gọi _loadUserData() ở đây nữa
                            // vì stream authStateChanges đã xử lý
                            // Tuy nhiên, nếu bạn muốn cập nhật SharedPreferences ngay lập tức, có thể gọi setLoginSuccess(true);
                            // _loadUserData();
                          },
                          onLoginStateChanged: setLoginSuccess,
                        ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(t.login, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.ifDontHaveAccount),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegisterScreen(
                              onLanguageChanged: widget.onLanguageChanged,
                              onLoginSuccess: () {
                                // Tương tự, không cần gọi _loadUserData() ở đây nữa
                                // _loadUserData();
                              },
                              onLoginStateChanged: setLoginSuccess,
                            ),
                      ),
                    );
                  },
                  child: Text(t.register),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              _avatarUrl != null && _avatarUrl!.isNotEmpty
                  ? NetworkImage(_avatarUrl!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
        ),
        const SizedBox(height: 12),
        Text(
          _userName ?? 'Chưa cập nhật tên',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/edit-profile');
          },
          child: Text(AppLocalizations.of(context)!.editProfile),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // _logout(); // Không cần gọi ở đây vì authStateChanges đã xử lý
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: Text(
            AppLocalizations.of(context)!.logout,
            style: const TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
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
        side: const BorderSide(color: Colors.orange, width: 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.orange,
        ),
        onTap: onTap,
      ),
    );
  }
}
