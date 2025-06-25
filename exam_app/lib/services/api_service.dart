import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/exam.dart';
import '../models/exam_session.dart';
import '../models/statistics.dart';
import '../models/request_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // User endpoints
  Future<User> createUser(UserCreateRequest request) async {
    try {
      final response = await _dio.post('/users', data: request.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserByUsername(String username) async {
    try {
      final response = await _dio.get('/users/username/$username');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Exam endpoints
  Future<Exam> createExam(ExamCreateRequest request) async {
    try {
      final response = await _dio.post('/exams', data: request.toJson());
      return Exam.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Exam> getExam(int examId, int userId) async {
    try {
      final response = await _dio.get('/exams/$examId?userId=$userId');
      return Exam.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Exam>> getExamsByHost(int hostUserId) async {
    try {
      final response = await _dio.get('/exams/host/$hostUserId');
      return (response.data as List)
          .map((json) => Exam.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExamSession> joinExam(ExamJoinRequest request) async {
    try {
      final response = await _dio.post('/exams/join', data: request.toJson());
      return ExamSession.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Exam> activateExam(int examId) async {
    try {
      final response = await _dio.put('/exams/$examId/activate');
      return Exam.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> submitAnswer(AnswerSubmissionRequest request) async {
    try {
      await _dio.post('/exams/answer', data: request.toJson());
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExamSession> completeExam(int sessionId) async {
    try {
      final response = await _dio.put('/exams/sessions/$sessionId/complete');
      return ExamSession.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Statistics endpoints
  Future<StatisticsResponse> getExamStatistics(int examId) async {
    try {
      final response = await _dio.get('/exams/$examId/statistics');
      return StatisticsResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<QuestionStatistics>> getMostDifficultQuestions(int examId, {int limit = 5}) async {
    try {
      final response = await _dio.get('/exams/$examId/statistics/difficult-questions?limit=$limit');
      return (response.data as List)
          .map((json) => QuestionStatistics.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<QuestionStatistics>> getMostCorrectQuestions(int examId, {int limit = 5}) async {
    try {
      final response = await _dio.get('/exams/$examId/statistics/correct-questions?limit=$limit');
      return (response.data as List)
          .map((json) => QuestionStatistics.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<UserStatistics>> getTopPerformers(int examId, {int limit = 10}) async {
    try {
      final response = await _dio.get('/exams/$examId/statistics/top-performers?limit=$limit');
      return (response.data as List)
          .map((json) => UserStatistics.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<double> getExamProgress(int sessionId) async {
    try {
      final response = await _dio.get('/exams/sessions/$sessionId/progress');
      return (response.data as num).toDouble();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['error'] ?? 'Server error occurred';
          return Exception('Server error ($statusCode): $message');
        case DioExceptionType.cancel:
          return Exception('Request was cancelled');
        default:
          return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unexpected error: $error');
  }
}