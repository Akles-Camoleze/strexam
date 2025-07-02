import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam_session.dart';
import '../widgets/common/loading_widget.dart';
import 'session_responses_screen.dart';

class UserSessionsScreen extends StatefulWidget {
  final int examId;
  final String examTitle;
  final int userId;

  const UserSessionsScreen({
    Key? key,
    required this.examId,
    required this.examTitle,
    required this.userId,
  }) : super(key: key);

  @override
  _UserSessionsScreenState createState() => _UserSessionsScreenState();
}

class _UserSessionsScreenState extends State<UserSessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserSessions();
    });
  }

  void _loadUserSessions() {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    examProvider.loadUserSessions(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sessões: ${widget.examTitle}'),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          final sessions = examProvider.userSessions
              .where((session) => session.examId == widget.examId)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suas sessões neste exame',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veja suas tentativas e pontuações',
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
                      onPressed: _loadUserSessions,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Atualizar',
                    ),
                  ],
                ),

                Expanded(
                  child: examProvider.isLoading
                      ? const LoadingWidget()
                      : examProvider.error != null
                          ? _buildErrorState(examProvider.error!)
                          : sessions.isEmpty
                              ? _buildEmptyState()
                              : _buildSessionsList(sessions),
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
            onPressed: _loadUserSessions,
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
            Icons.history_edu_outlined,
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
            'Você ainda não participou deste exame ou suas sessões foram removidas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<ExamSession> sessions) {
    sessions.sort((a, b) => b.startedAt!.compareTo(a.startedAt!));

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
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
            title: Text(
              'Sessão #${session.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${session.status.name.toUpperCase()}'),
                Text('Iniciado em: ${_formatDateTime(session.startedAt!)}'),
                if (session.completedAt != null)
                  Text('Concluído em: ${_formatDateTime(session.completedAt!)}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pontuação: ${session.totalScore}/${session.maxScore}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => _navigateToSessionResponses(session),
              tooltip: 'Ver Respostas',
            ),
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
        return Icons.pending;
      case SessionStatus.completed:
        return Icons.check;
      case SessionStatus.abandoned:
        return Icons.cancel;
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
