import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimerWidget({
    Key? key,
    required this.remainingSeconds,
    required this.totalSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final isWarning = remainingSeconds <= 300; // 5 minutes
    final isCritical = remainingSeconds <= 60; // 1 minute

    Color getColor() {
      if (isCritical) return Colors.red;
      if (isWarning) return Colors.orange;
      return Colors.green;
    }

    return Row(
      children: [
        Icon(
          Icons.timer,
          color: getColor(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tempo Restante',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getColor(),
                    ),
                  ),
                  Text(
                    _formatTime(remainingSeconds),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: getColor(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(getColor()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
}