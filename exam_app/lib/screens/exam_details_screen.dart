import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/exam.dart';
import '../models/question.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/loading_widget.dart';
import 'statistics_screen.dart';

class ExamDetailsScreen extends StatefulWidget {
  final int examId;

  const ExamDetailsScreen({Key? key, required this.examId}) : super(key: key);

  @override
  _ExamDetailsScreenState createState() => _ExamDetailsScreenState();
}

class _ExamDetailsScreenState extends State<ExamDetailsScreen> {
  final ApiService _apiService = ApiService();

  Exam? _exam;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExamDetails();
  }

  void _loadExamDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final exam = await _apiService.getExam(widget.examId, authProvider.currentUser!.id);
        setState(() {
          _exam = exam;
          _isLoading = false;
        });
      } else {
        throw Exception('Usuário não autenticado');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exam?.title ?? 'Detalhes do Exame'),
        actions: [
          if (_exam != null)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'statistics',
                  child: Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Visualizar Estastísticas'),
                    ],
                  ),
                ),
                if (_exam?.status == ExamStatus.draft)
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Ativar Exame'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Compartilhar Código'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Atualizar'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Carregando detalhes do exame...');
    }

    if (_error != null) {
      return CustomErrorWidget(
        title: 'Falha ao carregar exame',
        message: _error!,
        onRetry: _loadExamDetails,
        icon: Icons.quiz_outlined,
      );
    }

    if (_exam == null) {
      return const CustomErrorWidget(
        title: 'Exame não encontrado',
        message: 'O exame informado não pode ser encontrado.',
        icon: Icons.search_off,
      );
    }

    return _buildExamDetails();
  }

  Widget _buildExamDetails() {
    return RefreshIndicator(
      onRefresh: () async => _loadExamDetails(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildExamInfoCard(),

          const SizedBox(height: 16),

          _buildStatusCard(),

          const SizedBox(height: 16),

          _buildQuickStatsCard(),

          const SizedBox(height: 16),

          _buildQuestionsSection(),

          const SizedBox(height: 16),

          _buildActionsSection(),
        ],
      ),
    );
  }

  Widget _buildExamInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.quiz, color: Colors.blue[700], size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informação do Exame',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        'Detalhes e configuração',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('Título', _exam!.title),
            _buildInfoRow('Descrição', _exam!.description ?? 'Descrição não informada'),
            _buildInfoRow('Código', _exam!.joinCode, highlight: true, copyable: true),
            _buildInfoRow('Tempo de Duração',
                _exam!.timeLimit != null ? '${_exam!.timeLimit} minutos' : 'Sem tempo de duração'),
            _buildInfoRow('Permitir Retomada', _exam!.allowRetake ? 'Sim' : 'Não'),
            _buildInfoRow('Criado', _formatDate(_exam!.createdAt)),
            if (_exam!.updatedAt != null && _exam!.updatedAt != _exam!.createdAt)
              _buildInfoRow('Última Atualização', _formatDate(_exam!.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _exam!.status;
    final color = _getStatusColor(status);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_getStatusIcon(status), color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Atual',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusDescription(status),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    final questions = _exam!.questions ?? [];
    final totalPoints = _getTotalPoints(questions);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estastísticas Rápidas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Quantidade de Questões',
                    questions.length.toString(),
                    Icons.quiz,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pontuação Total',
                    totalPoints.toString(),
                    Icons.score,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Tipos de Questões',
                    _getUniqueQuestionTypes(questions).toString(),
                    Icons.category,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    final questions = _exam!.questions ?? [];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questões (${questions.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (questions.isNotEmpty)
                  Chip(
                    label: Text('${_getTotalPoints(questions)} pontos no total'),
                    backgroundColor: Colors.blue[100],
                    avatar: const Icon(Icons.score, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (questions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.quiz_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma questão adicionada até o momento',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return _buildQuestionItem(index + 1, question);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(int number, Question question) {
    final hasAnswers = question.answers != null && question.answers!.isNotEmpty;

    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: _getQuestionTypeColor(question.type),
        child: Text(
          number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        'Questão $number',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Chip(
                  label: Text(_getQuestionTypeDisplay(question.type)),
                  backgroundColor: _getQuestionTypeColor(question.type).withOpacity(0.2),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${question.points} pts'),
                backgroundColor: Colors.grey[200],
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (hasAnswers) ...[
                const SizedBox(height: 16),
                Text(
                  'Opções de Respostas:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...question.answers!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  final isCorrect = answer.isCorrect == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green[50] : Colors.white,
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCorrect ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('${String.fromCharCode(65 + index)}. '),
                        Expanded(child: Text(answer.answerText)),
                        if (isCorrect)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Correta',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ] else if (question.type == QuestionType.shortAnswer) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Questão aberta - Alunos responderão manualmente',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (_exam!.status == ExamStatus.draft)
                  ElevatedButton.icon(
                    onPressed: () => _handleMenuAction('activate'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Ativar Exame'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _handleMenuAction('statistics'),
                  icon: const Icon(Icons.analytics),
                  label: const Text('Visualizar Estastísticas'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleMenuAction('share'),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar Código'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false, bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                      color: highlight ? Colors.blue[700] : Colors.black87,
                      fontSize: highlight ? 16 : 14,
                    ),
                  ),
                ),
                if (copyable)
                  IconButton(
                    onPressed: () => _copyToClipboard(value),
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copiar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ExamStatus status) {
    switch (status) {
      case ExamStatus.draft:
        return Colors.orange;
      case ExamStatus.active:
        return Colors.green;
      case ExamStatus.completed:
        return Colors.blue;
      case ExamStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ExamStatus status) {
    switch (status) {
      case ExamStatus.draft:
        return Icons.edit;
      case ExamStatus.active:
        return Icons.play_arrow;
      case ExamStatus.completed:
        return Icons.check;
      case ExamStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(ExamStatus status) {
    switch (status) {
      case ExamStatus.draft:
        return 'Exame está sendo preparado e ainda não está disponível para os alunos';
      case ExamStatus.active:
        return 'Exame está ativo e os alunos podem participar usando o código';
      case ExamStatus.completed:
        return 'Exame foi finalizado e os resultados estão disponíveis';
      case ExamStatus.cancelled:
        return 'Exame foi cancelado';
    }
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Colors.blue;
      case QuestionType.trueFalse:
        return Colors.green;
      case QuestionType.shortAnswer:
        return Colors.purple;
    }
  }

  String _getQuestionTypeDisplay(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Múltipla Escolha';
      case QuestionType.trueFalse:
        return 'Verdadeiro/Falso';
      case QuestionType.shortAnswer:
        return 'Aberta';
    }
  }

  int _getTotalPoints(List<Question> questions) {
    return questions.fold(0, (sum, question) => sum + question.points);
  }

  int _getUniqueQuestionTypes(List<Question> questions) {
    return questions.map((q) => q.type).toSet().length;
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} às '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copied to clipboard!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleMenuAction(String action) async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    switch (action) {
      case 'activate':
        if (_exam!.status == ExamStatus.draft) {
          final success = await examProvider.activateExam(widget.examId);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exam activated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            _loadExamDetails(); // Refresh
          } else if (mounted && examProvider.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(examProvider.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
      case 'statistics':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatisticsScreen(examId: widget.examId),
          ),
        );
        break;
      case 'share':
        _shareExamCode();
        break;
      case 'refresh':
        _loadExamDetails();
        break;
    }
  }

  void _shareExamCode() {
    if (_exam?.joinCode != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.share, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Share Exam Code'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share this code with your students:'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _exam!.joinCode,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            _copyToClipboard(_exam!.joinCode);
                          },
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy code',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _exam!.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Students need this code to join the exam',
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _copyToClipboard(_exam!.joinCode);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Code'),
            ),
          ],
        ),
      );
    }
  }
}