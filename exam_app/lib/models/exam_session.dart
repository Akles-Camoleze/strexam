import 'package:json_annotation/json_annotation.dart';

part 'exam_session.g.dart';

@JsonSerializable()
class ExamSession {
  final int id;
  final int examId;
  final int userId;
  final SessionStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int totalScore;
  final int maxScore;
  final double? percentage;

  ExamSession({
    required this.id,
    required this.examId,
    required this.userId,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.totalScore,
    required this.maxScore,
    this.percentage,
  });

  factory ExamSession.fromJson(Map<String, dynamic> json) => _$ExamSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ExamSessionToJson(this);
}

enum SessionStatus {
  @JsonValue('STARTED')
  started,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('ABANDONED')
  abandoned,
}