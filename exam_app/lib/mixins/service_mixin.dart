import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../services/storage_service.dart';

mixin ServiceMixin {
  final StorageService _storageService = StorageService();

  late final Dio _dio = _createDio();

  Dio get dio => _dio;

  Dio _createDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    return dio;
  }

  Exception handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Verifique sua conexão com a internet.');
        case DioExceptionType.badResponse:
          final message = error.response?.data?['error'] ?? 'Ocorreu um erro no servidor';
          return Exception(message);
        case DioExceptionType.cancel:
          return Exception('Requisição cancelada');
        default:
          return Exception(error.message);
      }
    }
    return Exception(error);
  }
}
