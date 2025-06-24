import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dat_ve_xe/service/connectivity_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);
    if (connectivityService.isConnected) return const SizedBox.shrink();
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: const Text("Không có kết nối mạng"),
      content: const Text("Vui lòng kiểm tra kết nối mạng của bạn."),
      actions: [
        TextButton(
          onPressed: () => connectivityService.retry(),
          child: Text(t.retry),
        ),
      ],
    );
  }
}
