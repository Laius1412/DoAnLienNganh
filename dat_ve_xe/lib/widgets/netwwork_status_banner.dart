import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dat_ve_xe/service/connectivity_service.dart'; // thay bằng path của bạn

class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);
    if (connectivityService.isConnected) return const SizedBox.shrink();

    return AlertDialog(
      title: const Text("Không có kết nối mạng"),
      content: const Text("Vui lòng kiểm tra kết nối mạng của bạn."),
      actions: [
        TextButton(
          onPressed: () => connectivityService.retry(),
          child: const Text("Thử lại"),
        ),
      ],
    );
  }
}
