import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../widgets/common/loading_widget.dart';

class SessionCorrectionScreen extends StatefulWidget {
  final int sessionId;
  final int examId;
  final String examTitle;

  const SessionCorrectionScreen({
    Key? key,
    required this.sessionId,
    required this.examId,
    required this.examTitle,
  }) : super(key: key);

  @override
  _SessionCorrectionScreenState createState() => _SessionCorrectionScreenState();
}

class _SessionCorrectionScreenState extends State<SessionCorrectionScreen> {
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
        title: Text('Correção: ${widget.examTitle}'),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Correção de Respostas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Corrija as respostas de questões abertas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Refresh button
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
    // Filter to only show short answer questions
    final shortAnswerResponses = responses
        .where((response) => response['questionType'] == 'SHORT_ANSWER')
        .toList();

    if (shortAnswerResponses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma questão aberta encontrada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este exame não possui questões de resposta aberta para correção',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sort responses by question ID
    shortAnswerResponses.sort((a, b) => (a['questionId'] as int).compareTo(b['questionId'] as int));

    return ListView.builder(
      itemCount: shortAnswerResponses.length,
      itemBuilder: (context, index) {
        final response = shortAnswerResponses[index];
        final isCorrect = response['isCorrect'] as bool? ?? false;
        final pointsEarned = response['pointsEarned'] as int? ?? 0;
        final questionPoints = response['questionPoints'] as int? ?? 0;
        final questionText = response['questionText'] as String? ?? 'Questão sem texto';
        final responseText = response['responseText'] as String? ?? 'Sem resposta';
        final responseId = response['id'] as int;

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
                const SizedBox(height: 16),
                Text(
                  'Resposta do aluno:',
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
                    responseText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAnswer(responseId, false),
                        icon: const Icon(Icons.close),
                        label: const Text('Incorreta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAnswer(responseId, true),
                        icon: const Icon(Icons.check),
                        label: const Text('Correta'),
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
        );
      },
    );
  }

  void _markAnswer(int responseId, bool isCorrect) async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    
    final success = await examProvider.updateShortAnswerCorrection(responseId, isCorrect);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resposta marcada como ${isCorrect ? 'correta' : 'incorreta'}'),
          backgroundColor: isCorrect ? Colors.green : Colors.red,
        ),
      );
    } else if (mounted && examProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(examProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}