import 'package:json_annotation/json_annotation.dart';

part 'statistics.g.dart';

@JsonSerializable()
class ExamStatistics {
  final int examId;
  final String examTitle;
  final int totalParticipants;
  final int completedParticipants;
  final double averageScore;
  final double completionRate;
  final int totalQuestions;

  ExamStatistics({
    required this.examId,
    required this.examTitle,
    required this.totalParticipants,
    required this.completedParticipants,
    required this.averageScore,
    required this.completionRate,
    required this.totalQuestions,
  });

  factory ExamStatistics.fromJson(Map<String, dynamic> json) => _$ExamStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$ExamStatisticsToJson(this);
}

@JsonSerializable()
class QuestionStatistics {
  final int questionId;
  final String questionText;
  final int totalResponses;
  final int correctResponses;
  final double correctPercentage;
  final bool isMostDifficult;
  final bool isMostCorrect;

  QuestionStatistics({
    required this.questionId,
    required this.questionText,
    required this.totalResponses,
    required this.correctResponses,
    required this.correctPercentage,
    required this.isMostDifficult,
    required this.isMostCorrect,
  });

  factory QuestionStatistics.fromJson(Map<String, dynamic> json) => _$QuestionStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionStatisticsToJson(this);
}

@JsonSerializable()
class UserStatistics {
  final int userId;
  final String username;
  final String fullName;
  final int questionsAnswered;
  final int correctAnswers;
  final double currentPercentage;
  final String status;
  final DateTime? startedAt;
  final DateTime? lastActivity;

  UserStatistics({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.currentPercentage,
    required this.status,
    this.startedAt,
    this.lastActivity,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) => _$UserStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatisticsToJson(this);
}

@JsonSerializable()
class StatisticsResponse {
  final ExamStatistics examStatistics;
  final List<QuestionStatistics> questionStatistics;
  final List<UserStatistics> userStatistics;

  StatisticsResponse({
    required this.examStatistics,
    required this.questionStatistics,
    required this.userStatistics,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) => _$StatisticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsResponseToJson(this);
}