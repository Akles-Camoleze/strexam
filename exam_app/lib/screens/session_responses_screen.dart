import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../widgets/common/loading_widget.dart';

class SessionResponsesScreen extends StatefulWidget {
  final int sessionId;
  final int examId;
  final String examTitle;

  const SessionResponsesScreen({
    Key? key,
    required this.sessionId,
    required this.examId,
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
        title: Text('Respostas - Sessão #${widget.sessionId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResponses,
          ),
        ],
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          if (examProvider.isLoadingResponses) {
            return const LoadingWidget();
          }

          if (examProvider.error != null) {
            return _buildErrorState(examProvider.error!);
          }

          if (examProvider.userResponses.isEmpty) {
            return _buildEmptyState();
          }

          // Filter only short answer responses
          final shortAnswerResponses = examProvider.userResponses
              .where((response) => 
                  response['questionType'] == 'SHORT_ANSWER' && 
                  response['responseText'] != null && 
                  response['responseText'].toString().isNotEmpty)
              .toList();

          if (shortAnswerResponses.isEmpty) {
            return _buildNoShortAnswersState();
          }

          return _buildResponsesList(shortAnswerResponses);
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
            'O participante não respondeu nenhuma questão.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadResponses,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoShortAnswersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.short_text,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma resposta curta encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'O participante não respondeu nenhuma questão de resposta curta.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadResponses,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesList(List<Map<String, dynamic>> responses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: responses.length,
      itemBuilder: (context, index) {
        final response = responses[index];
        final isCorrect = response['isCorrect'] as bool;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questão ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  response['questionText'] as String,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Resposta do participante:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    response['responseText'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Pontos possíveis: ${response['questionPoints']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    Text(
                      'Resposta correta?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isCorrect,
                      activeColor: Colors.green,
                      onChanged: (value) => _updateCorrection(response['id'] as int, value),
                    ),
                  ],
                ),
                if (isCorrect)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Resposta marcada como correta',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateCorrection(int responseId, bool isCorrect) async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final success = await examProvider.updateShortAnswerCorrection(responseId, isCorrect);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resposta ${isCorrect ? 'marcada como correta' : 'marcada como incorreta'}'),
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