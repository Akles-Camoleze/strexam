import 'package:dio/dio.dart';
import 'package:exam_app/mixins/service_mixin.dart';

import '../core/exceptions/server_exception.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/exam.dart';
import '../models/exam_session.dart';
import '../models/request_models.dart';
import '../models/user.dart';

class ApiService with ServiceMixin {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<AuthResponse> register(UserCreateRequest request) async {
    try {
      final response = await dio.post('/auth/register', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> login(AuthRequest request) async {
    try {
      final response = await dio.post('/auth/login', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserByUsername(String username) async {
    try {
      final response = await dio.get('/users/username/$username');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Exam> createExam(ExamCreateRequest request) async {
    try {
      final response = await dio.post('/exams', data: request.toJson());
      return Exam.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Exam> getExam(int examId, int userId) async {
    try {
      final response = await dio.get('/exams/$examId?userId=$userId');
      return Exam.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Exam>> getExamsByHost(int hostUserId) async {
    try {
      final response = await dio.get('/exams/host/$hostUserId');
      return (response.data as List)
          .map((json) => Exam.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Exam>> getExamsByParticipant(int userId) async {
    try {
      final response = await dio.get('/exams/participant/$userId');
      return (response.data as List)
          .map((json) => Exam.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ExamSession>> getSessionsByParticipant(int userId) async {
    try {
      final response = await dio.get('/exams/participant/$userId/sessions');
      return (response.data as List)
          .map((json) => ExamSession.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExamSession> joinExam(ExamJoinRequest request) async {
    try {
      final response = await dio.post('/exams/join', data: request.toJson());
      return ExamSession.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Exam> activateExam(int examId) async {
    try {
      final response = await dio.put('/exams/$examId/activate');
      return Exam.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> submitAnswer(AnswerSubmissionRequest request) async {
    try {
      await dio.post('/exams/answer', data: request.toJson());
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExamSession> completeExam(int sessionId) async {
    try {
      final response = await dio.put('/exams/sessions/$sessionId/complete');
      return ExamSession.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ExamSession>> getSessionsByExam(int examId) async {
    try {
      final response = await dio.get('/exams/$examId/sessions');
      return (response.data as List)
          .map((json) => ExamSession.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUserResponsesBySession(int sessionId) async {
    try {
      final response = await dio.get('/exams/sessions/$sessionId/responses');
      return (response.data as List)
          .map((json) => json as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateShortAnswerCorrection(int responseId, bool isCorrect) async {
    try {
      final response = await dio.put('/exams/responses/$responseId/correct?isCorrect=$isCorrect');
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
