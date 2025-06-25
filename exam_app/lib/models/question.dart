import 'package:json_annotation/json_annotation.dart';
import 'answer.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final int id;
  final int? examId;
  final String questionText;
  final QuestionType type;
  final int orderIndex;
  final int points;
  final List<Answer>? answers;

  Question({
    required this.id,
    this.examId,
    required this.questionText,
    required this.type,
    required this.orderIndex,
    required this.points,
    this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

enum QuestionType {
  @JsonValue('MULTIPLE_CHOICE')
  multipleChoice,
  @JsonValue('TRUE_FALSE')
  trueFalse,
  @JsonValue('SHORT_ANSWER')
  shortAnswer,
}