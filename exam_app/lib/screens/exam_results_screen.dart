import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../widgets/common/loading_widget.dart';

class ExamResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () {
              final examProvider = Provider.of<ExamProvider>(context, listen: false);
              examProvider.disconnectFromExam();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Home',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          final session = examProvider.currentSession;
          final exam = examProvider.currentExam;

          if (session == null || exam == null) {
            return const Center(child: Text('No exam data available'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Congratulations header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Exam Completed!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exam.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Results cards
                Expanded(
                  child: ListView(
                    children: [
                      // Score card
                      _buildResultCard(
                        'Your Score',
                        '${session.totalScore} / ${session.maxScore}',
                        session.percentage != null
                            ? '${session.percentage!.toStringAsFixed(1)}%'
                            : 'N/A',
                        Icons.score,
                        _getScoreColor(session.percentage ?? 0),
                      ),

                      const SizedBox(height: 16),

                      // Questions answered card
                      _buildResultCard(
                        'Questions Answered',
                        '${examProvider.answeredQuestionsCount}',
                        'out of ${exam.questions?.length ?? 0}',
                        Icons.quiz,
                        Colors.blue,
                      ),

                      const SizedBox(height: 16),

                      // Time taken card
                      _buildResultCard(
                        'Time Taken',
                        _getTimeTaken(session, exam),
                        exam.timeLimit != null ? 'Limit: ${exam.timeLimit} min' : 'No time limit',
                        Icons.timer,
                        Colors.orange,
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                examProvider.disconnectFromExam();
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              icon: const Icon(Icons.home),
                              label: const Text('Go to Home'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to detailed results
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Detailed results coming soon!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.analytics),
                              label: const Text('View Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _getTimeTaken(session, exam) {
    if (session.startedAt != null && session.completedAt != null) {
      final duration = session.completedAt!.difference(session.startedAt!);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
    return 'N/A';
  }
}