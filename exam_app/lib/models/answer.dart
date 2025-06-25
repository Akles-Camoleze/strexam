import 'package:json_annotation/json_annotation.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer {
  final int id;
  final int? questionId;
  final String answerText;
  final bool? isCorrect;
  final int orderIndex;

  Answer({
    required this.id,
    required this.questionId,
    required this.answerText,
    this.isCorrect,
    required this.orderIndex,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
