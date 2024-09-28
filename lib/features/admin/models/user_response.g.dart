// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: (json['metadata'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: const _IdConverter().fromJson(json['id']),
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      gender: json['gender'] as String?,
      ssn: (json['ssn'] as num?)?.toInt(),
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': const _IdConverter().toJson(instance.id),
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'avatar': instance.avatar,
      'gender': instance.gender,
      'ssn': instance.ssn,
      'dob': instance.dob?.toIso8601String(),
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
