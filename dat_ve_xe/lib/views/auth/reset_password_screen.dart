import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

enum ResetStep { enterEmail, enterCode, enterNewPassword }

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  ResetStep _step = ResetStep.enterEmail;
  String? _email;
  String? _verificationId;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _emailController.text.trim();
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        email,
      );
      if (methods.isEmpty) {
        setState(() {
          _error = AppLocalizations.of(context)!.emailNotRegistered;
          _loading = false;
        });
        return;
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _step = ResetStep.enterCode;
        _email = email;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.sendCodeError;
        _loading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // Firebase không trả về code cho client, nên bước này chỉ là hướng dẫn người dùng kiểm tra email
    // và nhấn tiếp tục để sang bước đổi mật khẩu
    setState(() {
      _step = ResetStep.enterNewPassword;
      _loading = false;
    });
  }

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();
    if (newPass != confirmPass) {
      setState(() {
        _error = AppLocalizations.of(context)!.passwordNotMatch;
        _loading = false;
      });
      return;
    }
    try {
      // Người dùng phải vào link trong email để đổi mật khẩu, không đổi trực tiếp qua app được
      // Nên chỉ thông báo cho người dùng kiểm tra email
      setState(() {
        _loading = false;
      });
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.success),
              content: Text(AppLocalizations.of(context)!.checkEmailToReset),
              actions: [
                TextButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
      );
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.resetPasswordError;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.resetPassword)),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_step == ResetStep.enterEmail) ...[
                    Text(t.enterYourEmail, style: theme.textTheme.titleMedium),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: t.email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _sendResetCode,
                      child:
                          _loading
                              ? const CircularProgressIndicator()
                              : Text(t.sendResetCode),
                    ),
                  ] else if (_step == ResetStep.enterCode) ...[
                    Text(
                      t.checkYourEmailForCode,
                      style: theme.textTheme.titleMedium,
                    ),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(labelText: t.enterCode),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _verifyCode,
                      child:
                          _loading
                              ? const CircularProgressIndicator()
                              : Text(t.verifyCode),
                    ),
                  ] else if (_step == ResetStep.enterNewPassword) ...[
                    Text(
                      t.enterNewPassword,
                      style: theme.textTheme.titleMedium,
                    ),
                    TextField(
                      controller: _newPassController,
                      decoration: InputDecoration(labelText: t.newPassword),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _confirmPassController,
                      decoration: InputDecoration(labelText: t.confirmPassword),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _resetPassword,
                      child:
                          _loading
                              ? const CircularProgressIndicator()
                              : Text(t.resetPassword),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
