// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamEvent _$ExamEventFromJson(Map<String, dynamic> json) => ExamEvent(
      type: $enumDecode(_$ExamEventTypeEnumMap, json['type']),
      examId: (json['examId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ExamEventToJson(ExamEvent instance) => <String, dynamic>{
      'type': _$ExamEventTypeEnumMap[instance.type]!,
      'examId': instance.examId,
      'userId': instance.userId,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$ExamEventTypeEnumMap = {
  ExamEventType.userJoined: 'USER_JOINED',
  ExamEventType.userLeft: 'USER_LEFT',
  ExamEventType.answerSubmitted: 'ANSWER_SUBMITTED',
  ExamEventType.examCompleted: 'EXAM_COMPLETED',
  ExamEventType.timeWarning: 'TIME_WARNING',
  ExamEventType.examEnded: 'EXAM_ENDED',
  ExamEventType.statisticsUpdated: 'STATISTICS_UPDATED',
};
