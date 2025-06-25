import 'package:flutter/material.dart';

class AppConstants {
  // API Endpoints
  static const String apiBaseUrl = 'http://localhost:8080/api';
  static const String streamBaseUrl = 'http://localhost:8080/api/stream';

  // Storage Keys
  static const String userStorageKey = 'current_user';
  static const String sessionStorageKey = 'current_session';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration streamReconnectDelay = Duration(seconds: 5);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 8.0;

  // Exam Constants
  static const int maxQuestionTypes = 3;
  static const int defaultQuestionPoints = 1;
  static const int maxAnswerOptions = 6;
  static const int minAnswerOptions = 2;

  // Time Constants
  static const int timeWarningMinutes = 5;
  static const int criticalTimeMinutes = 1;

  // Colors
  static const primaryColor = Colors.blue;
  static const successColor = Colors.green;
  static const warningColor = Colors.orange;
  static const errorColor = Colors.red;
  static const infoColor = Colors.blue;
}