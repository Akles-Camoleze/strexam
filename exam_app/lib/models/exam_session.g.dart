// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamSession _$ExamSessionFromJson(Map<String, dynamic> json) => ExamSession(
      id: (json['id'] as num).toInt(),
      examId: (json['examId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      totalScore: (json['totalScore'] as num).toInt(),
      maxScore: (json['maxScore'] as num).toInt(),
      percentage: (json['percentage'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ExamSessionToJson(ExamSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'examId': instance.examId,
      'userId': instance.userId,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'totalScore': instance.totalScore,
      'maxScore': instance.maxScore,
      'percentage': instance.percentage,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.started: 'STARTED',
  SessionStatus.inProgress: 'IN_PROGRESS',
  SessionStatus.completed: 'COMPLETED',
  SessionStatus.abandoned: 'ABANDONED',
};
