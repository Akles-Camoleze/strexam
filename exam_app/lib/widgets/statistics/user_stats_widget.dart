import 'package:flutter/material.dart';
import '../../models/statistics.dart';

class UserStatsWidget extends StatelessWidget {
  final List<UserStatistics> userStatistics;
  final List<UserStatistics> topPerformers;

  const UserStatsWidget({
    Key? key,
    required this.userStatistics,
    required this.topPerformers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top Performers
        if (topPerformers.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Melhores Desempenhos',
            Icons.emoji_events,
            Colors.amber,
          ),
          const SizedBox(height: 8),
          ...topPerformers.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return _buildTopPerformerCard(user, index + 1);
          }),
          const SizedBox(height: 24),
        ],

        // All Students
        _buildSectionHeader(
          context,
          'Todos Alunos',
          Icons.people,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        ...userStatistics.map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformerCard(UserStatistics user, int rank) {
    Color getRankColor() {
      switch (rank) {
        case 1:
          return Colors.amber;
        case 2:
          return Colors.grey[400]!;
        case 3:
          return Colors.brown[400]!;
        default:
          return Colors.blue;
      }
    }

    IconData getRankIcon() {
      switch (rank) {
        case 1:
          return Icons.looks_one;
        case 2:
          return Icons.looks_two;
        case 3:
          return Icons.looks_3;
        default:
          return Icons.person;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: rank <= 3 ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getRankColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                getRankIcon(),
                color: getRankColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.currentPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: getRankColor(),
                  ),
                ),
                Text(
                  '${user.correctAnswers}/${user.questionsAnswered}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserStatistics user) {
    Color getStatusColor() {
      switch (user.status.toUpperCase()) {
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

    IconData getStatusIcon() {
      switch (user.status.toUpperCase()) {
        case 'COMPLETED':
          return Icons.check_circle;
        case 'IN_PROGRESS':
          return Icons.play_circle;
        case 'STARTED':
          return Icons.radio_button_checked;
        default:
          return Icons.help;
      }
    }

    Color getPerformanceColor() {
      final percentage = user.currentPercentage;
      if (percentage >= 90) return Colors.green;
      if (percentage >= 80) return Colors.lightGreen;
      if (percentage >= 70) return Colors.orange;
      if (percentage >= 60) return Colors.deepOrange;
      return Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: getStatusColor().withOpacity(0.2),
                  child: Icon(
                    getStatusIcon(),
                    color: getStatusColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progresso: ${user.questionsAnswered} respondido',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Correta: ${user.correctAnswers}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (user.startedAt != null)
                        Text(
                          'Iniciado: ${_formatDateTime(user.startedAt!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.currentPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: getPerformanceColor(),
                        ),
                      ),
                      LinearProgressIndicator(
                        value: user.currentPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(getPerformanceColor()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}