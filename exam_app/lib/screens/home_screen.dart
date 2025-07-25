import 'package:exam_app/screens/user_sessions_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam.dart';
import '../mixins/error_clearing_mixin.dart';
import 'create_exam_screen.dart';
import 'join_exam_screen.dart';
import 'statistics_screen.dart';
import 'exam_details_screen.dart';
import 'sessions_list_screen.dart';
import '../widgets/common/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with SingleTickerProviderStateMixin, ErrorClearingMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to clear errors when tab changes
    addTabControllerListener(_tabController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExams();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadExams() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      examProvider.loadHostExams(authProvider.currentUser!.id);
      examProvider.loadJoinedExams(authProvider.currentUser!.id);
    }
  }

  void _loadHostExams() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      examProvider.loadHostExams(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strexam'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text(authProvider.currentUser?.fullName ?? 'Usuário'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ExamProvider>(
        builder: (context, authProvider, examProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo(a), ${authProvider.currentUser?.fullName ?? 'Usuário'}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToCreateExam(),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Exame'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToJoinExam(),
                        icon: const Icon(Icons.login),
                        label: const Text('Entrar no Exame'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Exames Criados'),
                    Tab(text: 'Exames Participados'),
                  ],
                ),
                const SizedBox(height: 16),

                // Refresh button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _loadExams,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Atualizar',
                    ),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      examProvider.isLoading
                          ? const LoadingWidget()
                          : examProvider.error != null
                          ? _buildErrorState(examProvider.error!)
                          : examProvider.hostExams.isEmpty
                          ? _buildEmptyState(isCreatedExams: true)
                          : _buildExamsList(examProvider.hostExams),

                      examProvider.isLoading
                          ? const LoadingWidget()
                          : examProvider.error != null
                          ? _buildErrorState(examProvider.error!)
                          : examProvider.joinedExams.isEmpty
                          ? _buildEmptyState(isCreatedExams: false)
                          : _buildJoinedExamsList(examProvider.joinedExams),
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
            'Erro ao carregar exames',
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
            onPressed: _loadHostExams,
            icon: const Icon(Icons.refresh),
            label: const Text('Tente novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isCreatedExams = true}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCreatedExams ? Icons.quiz_outlined : Icons.history_edu_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isCreatedExams 
                ? 'Não existem exames criados' 
                : 'Não existem exames participados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCreatedExams
                ? 'Crie o seu primeiro exame e aproveite!'
                : 'Participe de um exame usando o código de acesso',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: isCreatedExams 
                ? () => _navigateToCreateExam()
                : () => _navigateToJoinExam(),
            icon: Icon(isCreatedExams ? Icons.add : Icons.login),
            label: Text(isCreatedExams ? 'Criar Exame' : 'Entrar no Exame'),
            style: isCreatedExams 
                ? null 
                : ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinedExamsList(List<Exam> exams) {
    return ListView.builder(
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(exam.status),
              child: Icon(
                _getStatusIcon(exam.status),
                color: Colors.white,
              ),
            ),
            title: Text(
              exam.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exam.description != null && exam.description!.isNotEmpty)
                  Text(exam.description!),
                const SizedBox(height: 4),
                Text('Status: ${exam.status.name.toUpperCase()}'),
                if (exam.timeLimit != null)
                  Text('Duração: ${exam.timeLimit} minutos'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => _navigateToSessionsList(exam),
              tooltip: 'Ver Sessões',
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamsList(List<Exam> exams) {
    return ListView.builder(
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(exam.status),
              child: Icon(
                _getStatusIcon(exam.status),
                color: Colors.white,
              ),
            ),
            title: Text(
              exam.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exam.description != null && exam.description!.isNotEmpty)
                  Text(exam.description!),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Código: ${exam.joinCode}'),
                    const SizedBox(width: 16),
                    Text('Status: ${exam.status.name.toUpperCase()}'),
                  ],
                ),
                if (exam.timeLimit != null)
                  Text('Duração: ${exam.timeLimit} minutos'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleExamAction(value, exam),
              itemBuilder: (context) => [
                if (exam.status == ExamStatus.draft)
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Ativar'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'statistics',
                  child: Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Estastísticas'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Detalhes'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sessions',
                  child: Row(
                    children: [
                      Icon(Icons.people, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Sessões e Correções'),
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

  void _navigateToCreateExam() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateExamScreen()),
    ).then((_) => _loadHostExams());
  }

  void _navigateToJoinExam() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JoinExamScreen()),
    );
  }

  void _navigateToSessionsList(Exam exam) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSessionsScreen(
          examId: exam.id,
          examTitle: exam.title,
          userId: authProvider.currentUser!.id,
        ),
      ),
    );
  }

  void _handleExamAction(String action, Exam exam) async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    switch (action) {
      case 'activate':
        final success = await examProvider.activateExam(exam.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exame ativado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadHostExams(); // Refresh the list
        } else if (mounted && examProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(examProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      case 'statistics':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatisticsScreen(examId: exam.id),
          ),
        );
        break;
      case 'details':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamDetailsScreen(examId: exam.id),
          ),
        );
        break;
      case 'sessions':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SessionsListScreen(
              examId: exam.id,
              examTitle: exam.title,
            ),
          ),
        );
        break;
    }
  }

  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Tem certeza de que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final examProvider = Provider.of<ExamProvider>(context, listen: false);

      examProvider.disconnectFromExam();

      await authProvider.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Desconectado com sucesso'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }
}
