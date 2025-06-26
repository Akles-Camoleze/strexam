import 'package:flutter/material.dart';
import '../../models/statistics.dart';

class QuestionStatsWidget extends StatelessWidget {
  final List<QuestionStatistics> questionStatistics;
  final List<QuestionStatistics> difficultQuestions;
  final List<QuestionStatistics> correctQuestions;

  const QuestionStatsWidget({
    Key? key,
    required this.questionStatistics,
    required this.difficultQuestions,
    required this.correctQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Most Difficult Questions
        if (difficultQuestions.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Questões mais difíceis',
            Icons.trending_down,
            Colors.red,
          ),
          const SizedBox(height: 8),
          ...difficultQuestions.take(3).map((question) =>
              _buildQuestionCard(question, Colors.red[100]!, Colors.red[700]!)),
          const SizedBox(height: 24),
        ],

        // Most Correct Questions
        if (correctQuestions.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Questões mais assertivas',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 8),
          ...correctQuestions.take(3).map((question) =>
              _buildQuestionCard(question, Colors.green[100]!, Colors.green[700]!)),
          const SizedBox(height: 24),
        ],

        // All Questions Performance
        _buildSectionHeader(
          context,
          'Desempenho de todas as questões',
          Icons.quiz,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        ...questionStatistics.map((question) =>
            _buildDetailedQuestionCard(question)),
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

  Widget _buildQuestionCard(QuestionStatistics question, Color backgroundColor, Color textColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Correta: ${question.correctResponses}/${question.totalResponses}',
                  style: TextStyle(color: textColor),
                ),
                Text(
                  '${question.correctPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedQuestionCard(QuestionStatistics question) {
    final percentage = question.correctPercentage;
    Color getColor() {
      if (percentage >= 80) return Colors.green;
      if (percentage >= 60) return Colors.orange;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resposta: ${question.totalResponses}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Correta: ${question.correctResponses}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                  ),
                ),
              ],
            ),
            if (question.isMostDifficult || question.isMostCorrect) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (question.isMostDifficult)
                    Chip(
                      label: const Text('Mais difícil'),
                      backgroundColor: Colors.red[100],
                      avatar: const Icon(Icons.trending_down, size: 16, color: Colors.red),
                    ),
                  if (question.isMostCorrect)
                    Chip(
                      label: const Text('Mais assertiva'),
                      backgroundColor: Colors.green[100],
                      avatar: const Icon(Icons.trending_up, size: 16, color: Colors.green),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}