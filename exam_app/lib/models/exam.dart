import 'package:json_annotation/json_annotation.dart';
import 'question.dart';

part 'exam.g.dart';

@JsonSerializable()
class Exam {
  final int id;
  final String title;
  final String? description;
  final int hostUserId;
  final String joinCode;
  final ExamStatus status;
  final int? timeLimit;
  final bool allowRetake;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Question>? questions;

  Exam({
    required this.id,
    required this.title,
    this.description,
    required this.hostUserId,
    required this.joinCode,
    required this.status,
    this.timeLimit,
    required this.allowRetake,
    this.createdAt,
    this.updatedAt,
    this.questions,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);
}

enum ExamStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}