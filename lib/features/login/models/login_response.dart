import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse extends Equatable {
  final String message;
  final int status;
  final Metadata metadata;

  const LoginResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  @override
  List<Object?> get props => [message, status, metadata];

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class Metadata extends Equatable {
  final User user;
  final Tokens tokens;

  const Metadata({
    required this.user,
    required this.tokens,
  });

  @override
  List<Object?> get props => [user, tokens];

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataToJson(this);
}

@JsonSerializable()
class User extends Equatable {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String gender;
  final String dob;
  final int ssn;
  final String address;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String status;
  final String createdAt;
  final String updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    required this.gender,
    required this.dob,
    required this.ssn,
    required this.address,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    name,
    email,
    role,
    avatar,
    gender,
    dob,
    ssn,
    address,
    phoneNumber,
    status,
    createdAt,
    updatedAt,
  ];

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Tokens extends Equatable {
  final String accessToken;
  final String refreshToken;

  const Tokens({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];

  factory Tokens.fromJson(Map<String, dynamic> json) => _$TokensFromJson(json);

  Map<String, dynamic> toJson() => _$TokensToJson(this);
}
