// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exam _$ExamFromJson(Map<String, dynamic> json) => Exam(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      hostUserId: (json['hostUserId'] as num).toInt(),
      joinCode: json['joinCode'] as String,
      status: $enumDecode(_$ExamStatusEnumMap, json['status']),
      timeLimit: (json['timeLimit'] as num?)?.toInt(),
      allowRetake: json['allowRetake'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamToJson(Exam instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'hostUserId': instance.hostUserId,
      'joinCode': instance.joinCode,
      'status': _$ExamStatusEnumMap[instance.status]!,
      'timeLimit': instance.timeLimit,
      'allowRetake': instance.allowRetake,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'questions': instance.questions,
    };

const _$ExamStatusEnumMap = {
  ExamStatus.draft: 'DRAFT',
  ExamStatus.active: 'ACTIVE',
  ExamStatus.completed: 'COMPLETED',
  ExamStatus.cancelled: 'CANCELLED',
};
