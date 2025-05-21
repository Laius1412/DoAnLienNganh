import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dat_ve_xe/views/auth/login_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  const RegisterScreen({super.key, required this.onLanguageChanged});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  DateTime? _selectedDate;
  String _gender = 'male';
  bool _isLoading = false;

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange, width: 2),
    ),
  );

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.passwordMismatch)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Tạo tài khoản trong Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final fcmToken = await FirebaseMessaging.instance.getToken();
      // 2. Lưu thông tin người dùng vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'birth': _selectedDate?.toIso8601String() ?? '',
            'phone': _phoneController.text.trim(),
            'gender': _gender,
            'role': 'customer',
            'avt': '',
            'fcmToken': fcmToken ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => LoginScreen(
                onLanguageChanged: widget.onLanguageChanged,
                onLoginSuccess: () {},
              ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = t.weakPassword;
      } else if (e.code == 'email-already-in-use') {
        errorMessage = t.emailAlreadyUsed;
      } else {
        errorMessage = '${t.registerFailed}: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t.registerFailed}: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.register)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(t.name),
                    validator:
                        (value) => value!.isEmpty ? t.requiredField : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(t.email),
                    validator:
                        (value) => value!.isEmpty ? t.requiredField : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(t.phone),
                    validator: (value) {
                      final phone = value!.trim();
                      if (phone.isEmpty) return t.requiredField;
                      if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
                        return t.invalidPhone;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _birthDateController,
                        decoration: _inputDecoration(t.birthDate),
                        validator:
                            (value) => value!.isEmpty ? t.requiredField : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items:
                        _gender == 'female'
                            ? [
                              DropdownMenuItem(
                                value: 'female',
                                child: Text(t.female),
                              ),
                              DropdownMenuItem(
                                value: 'male',
                                child: Text(t.male),
                              ),
                            ]
                            : [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text(t.male),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text(t.female),
                              ),
                            ],
                    onChanged: (val) {
                      setState(() {
                        _gender = val!;
                      });
                    },
                    decoration: _inputDecoration(t.gender),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration(t.password),
                    validator:
                        (value) => value!.isEmpty ? t.requiredField : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration(t.confirmPassword),
                    validator:
                        (value) => value!.isEmpty ? t.requiredField : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(t.register),
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
