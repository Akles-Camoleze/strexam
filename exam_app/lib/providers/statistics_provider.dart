import 'package:flutter/foundation.dart';
import '../models/statistics.dart';
import '../services/api_service.dart';

class StatisticsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  StatisticsResponse? _examStatistics;
  List<QuestionStatistics> _difficultQuestions = [];
  List<QuestionStatistics> _correctQuestions = [];
  List<UserStatistics> _topPerformers = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  StatisticsResponse? get examStatistics => _examStatistics;
  List<QuestionStatistics> get difficultQuestions => _difficultQuestions;
  List<QuestionStatistics> get correctQuestions => _correctQuestions;
  List<UserStatistics> get topPerformers => _topPerformers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all statistics for an exam
  Future<void> loadExamStatistics(int examId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load main statistics
      _examStatistics = await _apiService.getExamStatistics(examId);

      // Load additional statistics in parallel
      final futures = await Future.wait([
        _apiService.getMostDifficultQuestions(examId, limit: 5),
        _apiService.getMostCorrectQuestions(examId, limit: 5),
        _apiService.getTopPerformers(examId, limit: 10),
      ]);

      _difficultQuestions = futures[0] as List<QuestionStatistics>;
      _correctQuestions = futures[1] as List<QuestionStatistics>;
      _topPerformers = futures[2] as List<UserStatistics>;

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load specific statistics
  Future<void> loadDifficultQuestions(int examId, {int limit = 5}) async {
    try {
      _difficultQuestions = await _apiService.getMostDifficultQuestions(examId, limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadCorrectQuestions(int examId, {int limit = 5}) async {
    try {
      _correctQuestions = await _apiService.getMostCorrectQuestions(examId, limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadTopPerformers(int examId, {int limit = 10}) async {
    try {
      _topPerformers = await _apiService.getTopPerformers(examId, limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get progress for a specific session
  Future<double> getSessionProgress(int sessionId) async {
    try {
      return await _apiService.getExamProgress(sessionId);
    } catch (e) {
      _setError(e.toString());
      return 0.0;
    }
  }

  // Refresh statistics
  Future<void> refreshStatistics(int examId) async {
    await loadExamStatistics(examId);
  }

  // Clear statistics
  void clearStatistics() {
    _examStatistics = null;
    _difficultQuestions.clear();
    _correctQuestions.clear();
    _topPerformers.clear();
    _clearError();
    notifyListeners();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get statistics summary
  Map<String, dynamic> getStatisticsSummary() {
    if (_examStatistics == null) return {};

    final stats = _examStatistics!.examStatistics;

    return {
      'totalParticipants': stats.totalParticipants,
      'completionRate': '${stats.completionRate.toStringAsFixed(1)}%',
      'averageScore': '${stats.averageScore.toStringAsFixed(1)}%',
      'totalQuestions': stats.totalQuestions,
      'mostDifficultQuestion': _difficultQuestions.isNotEmpty
          ? _difficultQuestions.first.questionText
          : 'N/A',
      'bestPerformer': _topPerformers.isNotEmpty
          ? _topPerformers.first.fullName
          : 'N/A',
    };
  }

  // Get question performance data for charts
  List<Map<String, dynamic>> getQuestionPerformanceData() {
    if (_examStatistics == null) return [];

    return _examStatistics!.questionStatistics.map((question) => {
      'questionId': question.questionId,
      'questionText': question.questionText.length > 30
          ? '${question.questionText.substring(0, 30)}...'
          : question.questionText,
      'correctPercentage': question.correctPercentage,
      'totalResponses': question.totalResponses,
    }).toList();
  }

  // Get user performance data for charts
  List<Map<String, dynamic>> getUserPerformanceData() {
    if (_examStatistics == null) return [];

    return _examStatistics!.userStatistics.map((user) => {
      'userId': user.userId,
      'username': user.username,
      'fullName': user.fullName,
      'percentage': user.currentPercentage,
      'questionsAnswered': user.questionsAnswered,
      'status': user.status,
    }).toList();
  }

  // Calculate completion rate by status
  Map<String, int> getCompletionByStatus() {
    if (_examStatistics == null) return {};

    final statusCounts = <String, int>{};

    for (final user in _examStatistics!.userStatistics) {
      statusCounts[user.status] = (statusCounts[user.status] ?? 0) + 1;
    }

    return statusCounts;
  }

  // Get performance distribution
  Map<String, int> getPerformanceDistribution() {
    if (_examStatistics == null) return {};

    final distribution = <String, int>{
      'Excelente (90-100%)': 0,
      'Bom (80-89%)': 0,
      'Média (70-79%)': 0,
      'Abaixo da Média (60-69%)': 0,
      'Ruim (0-59%)': 0,
    };

    for (final user in _examStatistics!.userStatistics) {
      final percentage = user.currentPercentage;

      if (percentage >= 90) {
        distribution['Excelente (90-100%)'] = distribution['Excelente (90-100%)']! + 1;
      } else if (percentage >= 80) {
        distribution['Bom (80-89%)'] = distribution['Bom (80-89%)']! + 1;
      } else if (percentage >= 70) {
        distribution['Média (70-79%)'] = distribution['Média (70-79%)']! + 1;
      } else if (percentage >= 60) {
        distribution['Abaixo da Média (60-69%)'] = distribution['Abaixo da Média (60-69%)']! + 1;
      } else {
        distribution['Ruim (0-59%)'] = distribution['Ruim (0-59%)']! + 1;
      }
    }

    return distribution;
  }
}