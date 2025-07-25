import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

@JsonSerializable()
class AuthRequest {
  final String username;
  final String password;

  const AuthRequest({
    required this.username,
    required this.password,
  });

  factory AuthRequest.fromJson(Map<String, dynamic> json) => _$AuthRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);

  @override
  String toString() {
    return 'AuthRequest{username: $username}';
  }
}