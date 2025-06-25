// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamStatistics _$ExamStatisticsFromJson(Map<String, dynamic> json) =>
    ExamStatistics(
      examId: (json['examId'] as num).toInt(),
      examTitle: json['examTitle'] as String,
      totalParticipants: (json['totalParticipants'] as num).toInt(),
      completedParticipants: (json['completedParticipants'] as num).toInt(),
      averageScore: (json['averageScore'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
    );

Map<String, dynamic> _$ExamStatisticsToJson(ExamStatistics instance) =>
    <String, dynamic>{
      'examId': instance.examId,
      'examTitle': instance.examTitle,
      'totalParticipants': instance.totalParticipants,
      'completedParticipants': instance.completedParticipants,
      'averageScore': instance.averageScore,
      'completionRate': instance.completionRate,
      'totalQuestions': instance.totalQuestions,
    };

QuestionStatistics _$QuestionStatisticsFromJson(Map<String, dynamic> json) =>
    QuestionStatistics(
      questionId: (json['questionId'] as num).toInt(),
      questionText: json['questionText'] as String,
      totalResponses: (json['totalResponses'] as num).toInt(),
      correctResponses: (json['correctResponses'] as num).toInt(),
      correctPercentage: (json['correctPercentage'] as num).toDouble(),
      isMostDifficult: json['isMostDifficult'] as bool,
      isMostCorrect: json['isMostCorrect'] as bool,
    );

Map<String, dynamic> _$QuestionStatisticsToJson(QuestionStatistics instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'questionText': instance.questionText,
      'totalResponses': instance.totalResponses,
      'correctResponses': instance.correctResponses,
      'correctPercentage': instance.correctPercentage,
      'isMostDifficult': instance.isMostDifficult,
      'isMostCorrect': instance.isMostCorrect,
    };

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) =>
    UserStatistics(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      questionsAnswered: (json['questionsAnswered'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      currentPercentage: (json['currentPercentage'] as num).toDouble(),
      status: json['status'] as String,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      lastActivity: json['lastActivity'] == null
          ? null
          : DateTime.parse(json['lastActivity'] as String),
    );

Map<String, dynamic> _$UserStatisticsToJson(UserStatistics instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'fullName': instance.fullName,
      'questionsAnswered': instance.questionsAnswered,
      'correctAnswers': instance.correctAnswers,
      'currentPercentage': instance.currentPercentage,
      'status': instance.status,
      'startedAt': instance.startedAt?.toIso8601String(),
      'lastActivity': instance.lastActivity?.toIso8601String(),
    };

StatisticsResponse _$StatisticsResponseFromJson(Map<String, dynamic> json) =>
    StatisticsResponse(
      examStatistics: ExamStatistics.fromJson(
          json['examStatistics'] as Map<String, dynamic>),
      questionStatistics: (json['questionStatistics'] as List<dynamic>)
          .map((e) => QuestionStatistics.fromJson(e as Map<String, dynamic>))
          .toList(),
      userStatistics: (json['userStatistics'] as List<dynamic>)
          .map((e) => UserStatistics.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StatisticsResponseToJson(StatisticsResponse instance) =>
    <String, dynamic>{
      'examStatistics': instance.examStatistics,
      'questionStatistics': instance.questionStatistics,
      'userStatistics': instance.userStatistics,
    };
