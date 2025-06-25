import 'package:json_annotation/json_annotation.dart';

part 'request_models.g.dart';

@JsonSerializable()
class ExamCreateRequest {
  final String title;
  final String? description;
  final int hostUserId;
  final int? timeLimit;
  final bool allowRetake;
  final List<QuestionCreateRequest> questions;

  ExamCreateRequest({
    required this.title,
    this.description,
    required this.hostUserId,
    this.timeLimit,
    required this.allowRetake,
    required this.questions,
  });

  factory ExamCreateRequest.fromJson(Map<String, dynamic> json) => _$ExamCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ExamCreateRequestToJson(this);
}

@JsonSerializable()
class QuestionCreateRequest {
  final String questionText;
  final String type;
  final int points;
  final List<AnswerCreateRequest>? answers;

  QuestionCreateRequest({
    required this.questionText,
    required this.type,
    required this.points,
    this.answers,
  });

  factory QuestionCreateRequest.fromJson(Map<String, dynamic> json) => _$QuestionCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionCreateRequestToJson(this);
}

@JsonSerializable()
class AnswerCreateRequest {
  final String answerText;
  final bool isCorrect;

  AnswerCreateRequest({
    required this.answerText,
    required this.isCorrect,
  });

  factory AnswerCreateRequest.fromJson(Map<String, dynamic> json) => _$AnswerCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerCreateRequestToJson(this);
}

@JsonSerializable()
class ExamJoinRequest {
  final String joinCode;
  final int userId;

  ExamJoinRequest({
    required this.joinCode,
    required this.userId,
  });

  factory ExamJoinRequest.fromJson(Map<String, dynamic> json) => _$ExamJoinRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ExamJoinRequestToJson(this);
}

@JsonSerializable()
class AnswerSubmissionRequest {
  final int sessionId;
  final int questionId;
  final int? answerId;
  final String? responseText;

  AnswerSubmissionRequest({
    required this.sessionId,
    required this.questionId,
    this.answerId,
    this.responseText,
  });

  factory AnswerSubmissionRequest.fromJson(Map<String, dynamic> json) => _$AnswerSubmissionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerSubmissionRequestToJson(this);
}

@JsonSerializable()
class UserCreateRequest {
  final String username;
  final String email;
  final String fullName;

  UserCreateRequest({
    required this.username,
    required this.email,
    required this.fullName,
  });

  factory UserCreateRequest.fromJson(Map<String, dynamic> json) => _$UserCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateRequestToJson(this);
}