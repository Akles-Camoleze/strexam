import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final int current;
  final int total;
  final double progress;

  const ProgressWidget({
    Key? key,
    required this.current,
    required this.total,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $current of $total',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% Complete',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }
}