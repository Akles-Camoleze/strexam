import 'package:json_annotation/json_annotation.dart';

part 'exam_event.g.dart';

@JsonSerializable()
class ExamEvent {
  final ExamEventType type;
  final int? examId;
  final int? userId;
  final dynamic data;
  final DateTime timestamp;

  ExamEvent({
    required this.type,
    this.examId,
    this.userId,
    this.data,
    required this.timestamp,
  });

  factory ExamEvent.fromJson(Map<String, dynamic> json) => _$ExamEventFromJson(json);
  Map<String, dynamic> toJson() => _$ExamEventToJson(this);
}

enum ExamEventType {
  @JsonValue('USER_JOINED')
  userJoined,
  @JsonValue('USER_LEFT')
  userLeft,
  @JsonValue('ANSWER_SUBMITTED')
  answerSubmitted,
  @JsonValue('EXAM_COMPLETED')
  examCompleted,
  @JsonValue('TIME_WARNING')
  timeWarning,
  @JsonValue('EXAM_ENDED')
  examEnded,
  @JsonValue('STATISTICS_UPDATED')
  statisticsUpdated,
}