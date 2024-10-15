import 'dart:io';

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
  final String? avatar; // Nullable
  final String? gender; // Nullable
  final int? ssn; // Nullable
  final DateTime? dob; // Nullable
  final String? address; // Nullable
  final String? phone_number; // Nullable
  final String? status; // Nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final File? selectedAvatarFile;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? tempAvatarUrl;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    this.avatar, // Nullable in the constructor
    this.gender, // Nullable in the constructor
    this.ssn, // Nullable in the constructor
    this.dob, // Nullable in the constructor
    this.address, // Nullable in the constructor
    this.phone_number, // Nullable in the constructor
    this.status, // Nullable in the constructor
    this.createdAt,
    this.updatedAt,
    this.selectedAvatarFile,
    this.tempAvatarUrl
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? gender,
    int? ssn,
    String? address,
    DateTime? dob,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatar,
    File? selectedAvatarFile,
    String? tempAvatarUrl
  }) {
    return User(
      id: id ?? this.id,
      username: username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone_number: phoneNumber ?? this.phone_number,
      ssn: ssn ?? this.ssn,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      selectedAvatarFile: selectedAvatarFile ?? this.selectedAvatarFile,
      tempAvatarUrl: tempAvatarUrl ?? this.tempAvatarUrl,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        // Allow props to be nullable
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
        phone_number,
        status,
        createdAt,
        updatedAt,
        gender,
        avatar,
        selectedAvatarFile,
        tempAvatarUrl
      ];
}
