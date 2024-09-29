import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse extends Equatable {
  final String message;
  final int status;
  final Metadata metadata;

  const UserResponse({
    required this.message,
    required this.status,
    required this.metadata,
  });

  // JSON serialization methods
  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  @override
  List<Object?> get props => [message, status, metadata];
}

@JsonSerializable()
class Metadata extends Equatable {
  final int total;
  final int totalPages;
  final List<User> users;

  const Metadata({
    required this.total,
    required this.totalPages,
    required this.users,
  });

  // JSON serialization methods
  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);
  Map<String, dynamic> toJson() => _$MetadataToJson(this);

  @override
  List<Object?> get props => [total, totalPages, users];
}


@JsonSerializable()
class User extends Equatable {
  @JsonKey(name: '_id')
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
