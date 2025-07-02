import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam_session.dart';
import '../widgets/common/loading_widget.dart';
import 'session_responses_screen.dart';

class SessionsListScreen extends StatefulWidget {
  final int examId;
  final String examTitle;

  const SessionsListScreen({
    Key? key,
    required this.examId,
    required this.examTitle,
  }) : super(key: key);

  @override
  _SessionsListScreenState createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }

  void _loadSessions() {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    examProvider.loadSessionsByExam(widget.examId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sessões - ${widget.examTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          if (examProvider.isLoadingSessions) {
            return const LoadingWidget();
          }

          if (examProvider.error != null) {
            return _buildErrorState(examProvider.error!);
          }

          if (examProvider.examSessions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSessionsList(examProvider.examSessions);
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
            'Erro ao carregar sessões',
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
            onPressed: _loadSessions,
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
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma sessão encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há participantes neste exame ainda.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadSessions,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<ExamSession> sessions) {
    // Sort sessions by status (completed first) and then by id
    final sortedSessions = List<ExamSession>.from(sessions)
      ..sort((a, b) {
        if (a.status == SessionStatus.completed && b.status != SessionStatus.completed) {
          return -1;
        } else if (a.status != SessionStatus.completed && b.status == SessionStatus.completed) {
          return 1;
        } else {
          return b.id.compareTo(a.id); // Most recent first
        }
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        final session = sortedSessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(session.status),
              child: Icon(
                _getStatusIcon(session.status),
                color: Colors.white,
              ),
            ),
            title: Text('Sessão #${session.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuário ID: ${session.userId}'),
                Text('Status: ${_getStatusText(session.status)}'),
                Text('Pontuação: ${session.totalScore}/${session.maxScore} (${session.percentage != null ? '${(session.percentage! * 100).toStringAsFixed(1)}%' : 'N/A'})'),
                if (session.startedAt != null)
                  Text('Iniciado em: ${_formatDateTime(session.startedAt!)}'),
                if (session.completedAt != null)
                  Text('Concluído em: ${_formatDateTime(session.completedAt!)}'),
              ],
            ),
            trailing: session.status == SessionStatus.completed
                ? IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _navigateToSessionResponses(session),
                  )
                : null,
          ),
        );
      },
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.started:
        return Colors.blue;
      case SessionStatus.inProgress:
        return Colors.orange;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.abandoned:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.started:
        return Icons.play_arrow;
      case SessionStatus.inProgress:
        return Icons.hourglass_empty;
      case SessionStatus.completed:
        return Icons.check;
      case SessionStatus.abandoned:
        return Icons.cancel;
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.started:
        return 'Iniciado';
      case SessionStatus.inProgress:
        return 'Em Progresso';
      case SessionStatus.completed:
        return 'Concluído';
      case SessionStatus.abandoned:
        return 'Abandonado';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToSessionResponses(ExamSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionResponsesScreen(
          sessionId: session.id,
          examId: widget.examId,
          examTitle: widget.examTitle,
        ),
      ),
    );
  }
}