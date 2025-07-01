import 'dart:async';

import 'package:exam_app/core/types/limited_sorted_list.dart';
import 'package:exam_app/services/statistics_service.dart';
import 'package:flutter/foundation.dart';

import '../models/statistics.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsService _apiService = StatisticsService();

  StatisticsResponse? _examStatistics;

  final LimitedSortedList<QuestionStatistics> _difficultQuestions = LimitedSortedList(
    maxSize: 5,
    comparator: (a, b) => a.correctPercentage.compareTo(b.correctPercentage)
  );

  final LimitedSortedList<QuestionStatistics> _correctQuestions = LimitedSortedList(
      maxSize: 5,
      comparator: (a, b) => b.correctPercentage.compareTo(a.correctPercentage)
  );

  final LimitedSortedList<UserStatistics> _topPerformers = LimitedSortedList(
      maxSize: 10,
      comparator: (a, b) => b.currentPercentage.compareTo(a.currentPercentage)
  );

  bool _isLoading = false;
  String? _error;

  StreamSubscription<StatisticsResponse>? _statisticsSubscription;
  StreamSubscription<QuestionStatistics>? _difficultQuestionsSubscription;
  StreamSubscription<QuestionStatistics>? _correctQuestionsSubscription;
  StreamSubscription<UserStatistics>? _topPerformersSubscription;

  StatisticsResponse? get examStatistics => _examStatistics;

  List<QuestionStatistics> get difficultQuestions => _difficultQuestions.items;

  List<QuestionStatistics> get correctQuestions => _correctQuestions.items;

  List<UserStatistics> get topPerformers => _topPerformers.items;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadExamStatistics(int examId) async {
    _setLoading(true);
    _clearError();

    try {
      _stopStreams();
      _clearLists();
      _startStreams(examId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _startStreams(int examId) {
    _statisticsSubscription =
        _apiService.watchExamStatistics(examId).listen((statistics) {
            _examStatistics = statistics;
            notifyListeners();
          },
          onError: (error) => _setError('Statistics: $error')
        );

    _difficultQuestionsSubscription =
        _apiService.watchDifficultQuestions(examId, limit: 5).listen((question) {
          print('bosta');
            _difficultQuestions.updateOrInsert(
                question,
                (q) => q.questionId == question.questionId
            );
            notifyListeners();
          },
          onError: (error) => _setError('Difficult: $error'),
        );

    _correctQuestionsSubscription =
        _apiService.watchMostCorrectQuestions(examId, limit: 5).listen((question) {
          _correctQuestions.updateOrInsert(
              question,
              (q) => q.questionId == question.questionId
          );
          notifyListeners();
        },
          onError: (error) => _setError('Correct: $error'),
        );

    _topPerformersSubscription =
        _apiService.watchTopPerformers(examId, limit: 10).listen((user) {
          _topPerformers.updateOrInsert(user, (u) => u.userId == user.userId);
          notifyListeners();
        },
          onError: (error) => _setError('Top performers: $error'),
        );
  }

  void _stopStreams() {
    _statisticsSubscription?.cancel();
    _difficultQuestionsSubscription?.cancel();
    _correctQuestionsSubscription?.cancel();
    _topPerformersSubscription?.cancel();
  }

  void _clearLists() {
    _difficultQuestions.clear();
    _correctQuestions.clear();
    _topPerformers.clear();
  }

  @override
  void dispose() {
    _stopStreams();
    super.dispose();
  }

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
  }

  void clearStatistics() {
    _stopStreams();
    _clearLists();
    _clearError();
    notifyListeners();
  }

  Map<String, dynamic> getStatisticsSummary() {
    return {
      'totalDifficultQuestions': _difficultQuestions.length,
      'totalCorrectQuestions': _correctQuestions.length,
      'totalTopPerformers': _topPerformers.length,
      'mostDifficultQuestion': _difficultQuestions.isNotEmpty
          ? _difficultQuestions.first.questionText
          : 'N/A',
      'bestPerformer': _topPerformers.isNotEmpty
          ? _topPerformers.first.fullName
          : 'N/A',
      'averageTopPerformerScore': _topPerformers.isNotEmpty
          ? '${(_topPerformers.map((u) => u.currentPercentage).reduce((a, b) => a + b) / _topPerformers.length).toStringAsFixed(1)}%'
          : 'N/A',
    };
  }

  List<Map<String, dynamic>> getQuestionPerformanceData() {
    if (_examStatistics == null) return [];

    return _examStatistics!.questionStatistics
        .map((question) => {
      'questionId': question.questionId,
      'questionText': question.questionText.length > 30
          ? '${question.questionText.substring(0, 30)}...'
          : question.questionText,
      'correctPercentage': question.correctPercentage,
      'totalResponses': question.totalResponses,
    })
        .toList();
  }

  List<Map<String, dynamic>> getUserPerformanceData() {
    if (_examStatistics == null) return [];

    return _examStatistics!.userStatistics
        .map((user) => {
      'userId': user.userId,
      'username': user.username,
      'fullName': user.fullName,
      'percentage': user.currentPercentage,
      'questionsAnswered': user.questionsAnswered,
      'status': user.status,
    })
        .toList();
  }

  Map<String, int> getCompletionByStatus() {
    if (_examStatistics == null) return {};

    final statusCounts = <String, int>{};

    for (final user in _examStatistics!.userStatistics) {
      statusCounts[user.status] = (statusCounts[user.status] ?? 0) + 1;
    }

    return statusCounts;
  }

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
        distribution['Excelente (90-100%)'] =
            distribution['Excelente (90-100%)']! + 1;
      } else if (percentage >= 80) {
        distribution['Bom (80-89%)'] = distribution['Bom (80-89%)']! + 1;
      } else if (percentage >= 70) {
        distribution['Média (70-79%)'] = distribution['Média (70-79%)']! + 1;
      } else if (percentage >= 60) {
        distribution['Abaixo da Média (60-69%)'] =
            distribution['Abaixo da Média (60-69%)']! + 1;
      } else {
        distribution['Ruim (0-59%)'] = distribution['Ruim (0-59%)']! + 1;
      }
    }

    return distribution;
  }
}
