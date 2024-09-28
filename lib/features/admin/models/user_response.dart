import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse extends Equatable {
  final String message;
  final int status;
  final List<User> metadata;

  UserResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  @override
  List<Object> get props => [message, status, metadata];
}

@JsonSerializable()
class User extends Equatable {
  @_IdConverter()
  final String id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String? avatar;       // Nullable
  final String? gender;       // Nullable
  final int? ssn;             // Nullable
  final DateTime? dob;        // Nullable
  final String? address;      // Nullable
  final String? phoneNumber;  // Nullable
  final String? status;       // Nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,              // Nullable in the constructor
    this.gender,              // Nullable in the constructor
    this.ssn,                 // Nullable in the constructor
    this.dob,                 // Nullable in the constructor
    this.address,             // Nullable in the constructor
    this.phoneNumber,         // Nullable in the constructor
    this.status,              // Nullable in the constructor
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [  // Allow props to be nullable
    id,
    username,
    name,
    email,
    role,
    avatar,
    gender,
    ssn,
    dob,
    address,
    phoneNumber,
    status,
    createdAt,
    updatedAt,
  ];
}


class _IdConverter implements JsonConverter<String, dynamic> {
  const _IdConverter();

  @override
  String fromJson(dynamic json) {
    if (json == null || json['_id'] == null) {
      return '';  // or some default value like 'unknown'
    }
    return json['_id'] as String;
  }

  @override
  dynamic toJson(String id) => {'_id': id};
}
