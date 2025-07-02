import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({Key? key}) : super(key: key);

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15.5, height: 1.6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.policyTitle),
        backgroundColor: const Color.fromARGB(255, 253, 109, 37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              AppLocalizations.of(context)!.policy1Title,
              AppLocalizations.of(context)!.policy1Content,
            ),
            _section(
              AppLocalizations.of(context)!.policy2Title,
              AppLocalizations.of(context)!.policy2Content,
            ),
            _section(
              AppLocalizations.of(context)!.policy3Title,
              AppLocalizations.of(context)!.policy3Content,
            ),
            _section(
              AppLocalizations.of(context)!.policy4Title,
              AppLocalizations.of(context)!.policy4Content,
            ),
            _section(
              AppLocalizations.of(context)!.policy5Title,
              AppLocalizations.of(context)!.policy5Content,
            ),
            _section(
              AppLocalizations.of(context)!.policy6Title,
              AppLocalizations.of(context)!.policy6Content,
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.policyFooter,
              style: TextStyle(
                fontSize: 14.5,
                color: Theme.of(context).colorScheme.onBackground,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 