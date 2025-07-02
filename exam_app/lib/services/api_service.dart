import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../core/exceptions/server_exception.dart';
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

  Future<List<ExamSession>> getSessionsByExam(int examId) async {
    try {
      final response = await _dio.get('/exams/$examId/sessions');
      return (response.data as List)
          .map((json) => ExamSession.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserResponsesBySession(int sessionId) async {
    try {
      final response = await _dio.get('/exams/sessions/$sessionId/responses');
      return (response.data as List)
          .map((json) => json as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateShortAnswerCorrection(int responseId, bool isCorrect) async {
    try {
      final response = await _dio.put('/exams/responses/$responseId/correct?isCorrect=$isCorrect');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return ServerException('Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final message = error.response?.data?['error'] ?? 'Server error occurred';
          return ServerException(message);
        case DioExceptionType.cancel:
          return ServerException('Request was cancelled');
        default:
          return ServerException('Network error: ${error.message}');
      }
    }
    return ServerException('Unexpected error: $error');
  }
}
