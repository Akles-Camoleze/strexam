import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/statistics/charts_widget.dart';
import '../widgets/statistics/user_stats_widget.dart';
import '../widgets/statistics/question_stats_widget.dart';

class StatisticsScreen extends StatefulWidget {
  final int examId;

  const StatisticsScreen({Key? key, required this.examId}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadStatistics() {
    final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    statisticsProvider.loadExamStatistics(widget.examId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Statistics'),
        actions: [
          IconButton(
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.quiz), text: 'Questions'),
            Tab(icon: Icon(Icons.people), text: 'Students'),
          ],
        ),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, statisticsProvider, _) {
          if (statisticsProvider.isLoading) {
            return const LoadingWidget(message: 'Loading statistics...');
          }

          if (statisticsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading statistics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(statisticsProvider.error!),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadStatistics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (statisticsProvider.examStatistics == null) {
            return const Center(child: Text('No statistics available'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(statisticsProvider),
              _buildQuestionsTab(statisticsProvider),
              _buildStudentsTab(statisticsProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(StatisticsProvider provider) {
    final stats = provider.examStatistics!.examStatistics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Total Participants',
              stats.totalParticipants.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Completion Rate',
              '${stats.completionRate.toStringAsFixed(1)}%',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Average Score',
              '${stats.averageScore.toStringAsFixed(1)}%',
              Icons.score,
              Colors.orange,
            ),
            _buildStatCard(
              'Total Questions',
              stats.totalQuestions.toString(),
              Icons.quiz,
              Colors.purple,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Charts section
        if (provider.examStatistics != null)
          ChartsWidget(
            questionData: provider.getQuestionPerformanceData(),
            userData: provider.getUserPerformanceData(),
            completionData: provider.getCompletionByStatus(),
            performanceData: provider.getPerformanceDistribution(),
          ),
      ],
    );
  }

  Widget _buildQuestionsTab(StatisticsProvider provider) {
    return QuestionStatsWidget(
      questionStatistics: provider.examStatistics!.questionStatistics,
      difficultQuestions: provider.difficultQuestions,
      correctQuestions: provider.correctQuestions,
    );
  }

  Widget _buildStudentsTab(StatisticsProvider provider) {
    return UserStatsWidget(
      userStatistics: provider.examStatistics!.userStatistics,
      topPerformers: provider.topPerformers,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}