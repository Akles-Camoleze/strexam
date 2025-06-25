import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Live' : 'Offline',
            style: TextStyle(
              color: isConnected ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}