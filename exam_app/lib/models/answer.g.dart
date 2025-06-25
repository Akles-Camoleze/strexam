// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
      id: (json['id'] as num).toInt(),
      questionId: (json['questionId'] as num?)?.toInt(),
      answerText: json['answerText'] as String,
      isCorrect: json['isCorrect'] as bool?,
      orderIndex: (json['orderIndex'] as num).toInt(),
    );

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'id': instance.id,
      'questionId': instance.questionId,
      'answerText': instance.answerText,
      'isCorrect': instance.isCorrect,
      'orderIndex': instance.orderIndex,
    };
