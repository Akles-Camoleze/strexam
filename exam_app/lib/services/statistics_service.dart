import 'package:exam_app/mixins/service_mixin.dart';
import 'package:exam_app/mixins/sse_service_mixin.dart';

import '../models/statistics.dart';

class StatisticsService with ServiceMixin, SSEServiceMixin {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  Stream<QuestionStatistics> watchDifficultQuestions(int examId, {int limit = 5}) {
    return connectToSSE<QuestionStatistics>(
      endpoint: '/exams/$examId/statistics/difficult-questions',
      queryParams: {'limit': limit},
      parser: (json) => QuestionStatistics.fromJson(json),
    );
  }

  Stream<StatisticsResponse> watchExamStatistics(int examId) {
    try {
      return connectToSSE<StatisticsResponse>(
        endpoint: '/exams/$examId/statistics',
        parser: (json) => StatisticsResponse.fromJson(json),
      );
    } catch (e) {
      throw handleError(e);
    }
  }

  Stream<QuestionStatistics> watchMostCorrectQuestions(int examId, {int limit = 5}) {
    return connectToSSE<QuestionStatistics>(
      endpoint: '/exams/$examId/statistics/correct-questions',
      queryParams: {'limit': limit},
      parser: (json) => QuestionStatistics.fromJson(json)
    );
  }

  Stream<UserStatistics> watchTopPerformers(int examId, {int limit = 10}) {
    return connectToSSE<UserStatistics>(
      endpoint: '/exams/$examId/statistics/top-performers',
      queryParams: {'limit': limit},
      parser: (json) => UserStatistics.fromJson(json),
    );
  }

  Future<double> getExamProgress(int sessionId) async {
    try {
      final response = await dio.get('/exams/sessions/$sessionId/progress');
      return (response.data as num).toDouble();
    } catch (e) {
      throw handleError(e);
    }
  }

}