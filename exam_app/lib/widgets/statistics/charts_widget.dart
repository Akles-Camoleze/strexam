import 'package:flutter/material.dart';

class ChartsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> questionData;
  final List<Map<String, dynamic>> userData;
  final Map<String, int> completionData;
  final Map<String, int> performanceData;

  const ChartsWidget({
    Key? key,
    required this.questionData,
    required this.userData,
    required this.completionData,
    required this.performanceData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribuição de Desempenho',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildPerformanceChart(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Completion Status Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status de conclusão',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildCompletionChart(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    // Simple bar chart representation
    return Column(
      children: performanceData.entries.map((entry) {
        final maxValue = performanceData.values.reduce((a, b) => a > b ? a : b);
        final percentage = maxValue > 0 ? entry.value / maxValue : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getPerformanceColor(entry.key)),
                ),
              ),
              const SizedBox(width: 8),
              Text('${entry.value}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompletionChart() {
    return Column(
      children: completionData.entries.map((entry) {
        final maxValue = completionData.values.reduce((a, b) => a > b ? a : b);
        final percentage = maxValue > 0 ? entry.value / maxValue : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(entry.key)),
                ),
              ),
              const SizedBox(width: 8),
              Text('${entry.value}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getPerformanceColor(String range) {
    if (range.contains('Excelente')) return Colors.green;
    if (range.contains('Bom')) return Colors.lightGreen;
    if (range.contains('Médio')) return Colors.orange;
    if (range.contains('Ruim')) return Colors.deepOrange;
    return Colors.red;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'STARTED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}