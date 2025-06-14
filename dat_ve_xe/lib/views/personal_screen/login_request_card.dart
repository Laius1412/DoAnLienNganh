import 'package:flutter/material.dart';
import 'package:dat_ve_xe/views/auth/login_screen.dart';
import 'package:dat_ve_xe/views/auth/register_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginRequestCard extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  const LoginRequestCard({Key? key, required this.onLanguageChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
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
                          onLanguageChanged: onLanguageChanged,
                          onLoginSuccess: () {},
                          onLoginStateChanged: (_) {},
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
                              onLanguageChanged: onLanguageChanged,
                              onLoginSuccess: () {},
                              onLoginStateChanged: (_) {},
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
}
