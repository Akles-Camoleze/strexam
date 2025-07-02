import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../widgets/common/loading_widget.dart';

class SessionResponsesScreen extends StatefulWidget {
  final int sessionId;
  final int? examId;
  final String examTitle;

  const SessionResponsesScreen({
    Key? key,
    required this.sessionId,
    this.examId,
    required this.examTitle,
  }) : super(key: key);

  @override
  _SessionResponsesScreenState createState() => _SessionResponsesScreenState();
}

class _SessionResponsesScreenState extends State<SessionResponsesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadResponses();
    });
  }

  void _loadResponses() {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    examProvider.loadUserResponsesBySession(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Respostas: ${widget.examTitle}'),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suas respostas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veja suas respostas e pontuações para cada questão',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _loadResponses,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Atualizar',
                    ),
                  ],
                ),

                Expanded(
                  child: examProvider.isLoadingResponses
                      ? const LoadingWidget()
                      : examProvider.error != null
                          ? _buildErrorState(examProvider.error!)
                          : examProvider.userResponses.isEmpty
                              ? _buildEmptyState()
                              : _buildResponsesList(examProvider.userResponses),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar respostas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadResponses,
            icon: const Icon(Icons.refresh),
            label: const Text('Tente novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.question_answer_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma resposta encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há respostas registradas para esta sessão',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesList(List<Map<String, dynamic>> responses) {
    responses.sort((a, b) => (a['questionId'] as int).compareTo(b['questionId'] as int));

    int totalPoints = 0;
    int maxPoints = 0;

    for (var response in responses) {
      totalPoints += (response['pointsEarned'] as int?) ?? 0;
      maxPoints += (response['questionPoints'] as int?) ?? 0;
    }

    return Column(
      children: [
        // Summary card
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pontuação Total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalPoints de $maxPoints pontos',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: totalPoints > (maxPoints / 2) ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: totalPoints > (maxPoints / 2) ? Colors.green[100] : Colors.red[100],
                  child: Text(
                    '${((totalPoints / maxPoints) * 100).round()}%',
                    style: TextStyle(
                      color: totalPoints > (maxPoints / 2) ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Responses list
        Expanded(
          child: ListView.builder(
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final response = responses[index];
              final isCorrect = response['isCorrect'] as bool? ?? false;
              final pointsEarned = response['pointsEarned'] as int? ?? 0;
              final questionPoints = response['questionPoints'] as int? ?? 0;
              final questionText = response['questionText'] as String? ?? 'Questão sem texto';
              final questionType = response['questionType'] as String? ?? 'UNKNOWN';
              final responseText = response['responseText'] as String?;
              final answerText = response['answerText'] as String?;

              final displayText = questionType == 'SHORT_ANSWER'
                  ? responseText 
                  : answerText;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Questão ${index + 1}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$pointsEarned/$questionPoints pts',
                              style: TextStyle(
                                color: isCorrect ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        questionText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tipo: $questionType',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sua resposta:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          displayText ?? 'Sem resposta',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
