// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: (json['id'] as num).toInt(),
      examId: (json['examId'] as num?)?.toInt(),
      questionText: json['questionText'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      orderIndex: (json['orderIndex'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'examId': instance.examId,
      'questionText': instance.questionText,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'orderIndex': instance.orderIndex,
      'points': instance.points,
      'answers': instance.answers,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 'MULTIPLE_CHOICE',
  QuestionType.trueFalse: 'TRUE_FALSE',
  QuestionType.shortAnswer: 'SHORT_ANSWER',
};
