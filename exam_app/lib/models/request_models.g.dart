// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamCreateRequest _$ExamCreateRequestFromJson(Map<String, dynamic> json) =>
    ExamCreateRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      hostUserId: (json['hostUserId'] as num).toInt(),
      timeLimit: (json['timeLimit'] as num?)?.toInt(),
      allowRetake: json['allowRetake'] as bool,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionCreateRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamCreateRequestToJson(ExamCreateRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'hostUserId': instance.hostUserId,
      'timeLimit': instance.timeLimit,
      'allowRetake': instance.allowRetake,
      'questions': instance.questions,
    };

QuestionCreateRequest _$QuestionCreateRequestFromJson(
        Map<String, dynamic> json) =>
    QuestionCreateRequest(
      questionText: json['questionText'] as String,
      type: json['type'] as String,
      points: (json['points'] as num).toInt(),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => AnswerCreateRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionCreateRequestToJson(
        QuestionCreateRequest instance) =>
    <String, dynamic>{
      'questionText': instance.questionText,
      'type': instance.type,
      'points': instance.points,
      'answers': instance.answers,
    };

AnswerCreateRequest _$AnswerCreateRequestFromJson(Map<String, dynamic> json) =>
    AnswerCreateRequest(
      answerText: json['answerText'] as String,
      isCorrect: json['isCorrect'] as bool,
    );

Map<String, dynamic> _$AnswerCreateRequestToJson(
        AnswerCreateRequest instance) =>
    <String, dynamic>{
      'answerText': instance.answerText,
      'isCorrect': instance.isCorrect,
    };

ExamJoinRequest _$ExamJoinRequestFromJson(Map<String, dynamic> json) =>
    ExamJoinRequest(
      joinCode: json['joinCode'] as String,
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$ExamJoinRequestToJson(ExamJoinRequest instance) =>
    <String, dynamic>{
      'joinCode': instance.joinCode,
      'userId': instance.userId,
    };

AnswerSubmissionRequest _$AnswerSubmissionRequestFromJson(
        Map<String, dynamic> json) =>
    AnswerSubmissionRequest(
      sessionId: (json['sessionId'] as num).toInt(),
      questionId: (json['questionId'] as num).toInt(),
      answerId: (json['answerId'] as num?)?.toInt(),
      responseText: json['responseText'] as String?,
    );

Map<String, dynamic> _$AnswerSubmissionRequestToJson(
        AnswerSubmissionRequest instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'questionId': instance.questionId,
      'answerId': instance.answerId,
      'responseText': instance.responseText,
    };

UserCreateRequest _$UserCreateRequestFromJson(Map<String, dynamic> json) =>
    UserCreateRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
    );

Map<String, dynamic> _$UserCreateRequestToJson(UserCreateRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'fullName': instance.fullName,
    };
