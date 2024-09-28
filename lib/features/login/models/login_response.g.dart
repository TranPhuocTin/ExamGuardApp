// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      message: json['message'] as String,
      status: (json['status'] as num).toInt(),
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'status': instance.status,
      'metadata': instance.metadata,
    };

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      tokens: Tokens.fromJson(json['tokens'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'user': instance.user,
      'tokens': instance.tokens,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['_id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String,
      gender: json['gender'] as String,
      dob: json['dob'] as String,
      ssn: (json['ssn'] as num).toInt(),
      address: json['address'] as String,
      phoneNumber: json['phone_number'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'avatar': instance.avatar,
      'gender': instance.gender,
      'dob': instance.dob,
      'ssn': instance.ssn,
      'address': instance.address,
      'phone_number': instance.phoneNumber,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

Tokens _$TokensFromJson(Map<String, dynamic> json) => Tokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$TokensToJson(Tokens instance) => <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
