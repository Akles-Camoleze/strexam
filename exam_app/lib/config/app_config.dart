class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:9000/api';
  static const String streamUrl = 'http://10.0.2.2:9000/api/stream';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String userKey = 'current_user';
  static const String sessionKey = 'current_session';
  static const String tokenKey = 'auth_token';
}
