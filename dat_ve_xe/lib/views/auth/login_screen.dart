import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dat_ve_xe/views/auth/register_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_ve_xe/views/auth/reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final VoidCallback onLoginSuccess;
  final Function(bool) onLoginStateChanged;

  const LoginScreen({
    Key? key,
    required this.onLanguageChanged,
    required this.onLoginSuccess,
    required this.onLoginStateChanged,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final t = AppLocalizations.of(context)!;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(t.enterAllFields);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        if (_rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userCredential.user!.uid);
          await prefs.setString('email', email);
        }

        // Lấy FCM token và cập nhật vào Firestore
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'fcmToken': fcmToken, 'isNotificationEnabled': true});
        }

        // _showMessage(t.loginSuccess);
        widget.onLoginStateChanged(true);

        await Future.delayed(const Duration(seconds: 2));

        widget.onLoginSuccess();

        if (!mounted) return;
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = t.accountNotFound;
          break;
        case 'wrong-password':
          errorMsg = t.wrongPassword;
          break;
        case 'invalid-email':
          errorMsg = t.invalidEmail;
          break;
        case 'user-disabled':
          errorMsg = t.accountDisabled;
          break;
        default:
          errorMsg = '${t.loginFailed}: ${e.message}';
      }
      _showMessage(errorMsg);
    } catch (e) {
      print('Login error: $e');
      _showMessage(t.loginFailed);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.login)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: loc.email,
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: loc.password,
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    Text(loc.rememberMe),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(loc.forgotPassword),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: Text(loc.login),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.ifDontHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RegisterScreen(
                                  onLanguageChanged: widget.onLanguageChanged,
                                  onLoginSuccess: widget.onLoginSuccess,
                                  onLoginStateChanged:
                                      widget.onLoginStateChanged,
                                ),
                          ),
                        );
                      },
                      child: Text(loc.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Di chuyển overlay ra ngoài Column để phủ toàn màn hình
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
}
