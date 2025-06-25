import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  final int id;
  final int sessionId;
  final int questionId;
  final int? answerId;
  final String? responseText;
  final bool isCorrect;
  final int pointsEarned;
  final DateTime? respondedAt;

  UserResponse({
    required this.id,
    required this.sessionId,
    required this.questionId,
    this.answerId,
    this.responseText,
    required this.isCorrect,
    required this.pointsEarned,
    this.respondedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}
