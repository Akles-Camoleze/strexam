// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
      id: (json['id'] as num).toInt(),
      sessionId: (json['sessionId'] as num).toInt(),
      questionId: (json['questionId'] as num).toInt(),
      answerId: (json['answerId'] as num?)?.toInt(),
      responseText: json['responseText'] as String?,
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: (json['pointsEarned'] as num).toInt(),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'questionId': instance.questionId,
      'answerId': instance.answerId,
      'responseText': instance.responseText,
      'isCorrect': instance.isCorrect,
      'pointsEarned': instance.pointsEarned,
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };
