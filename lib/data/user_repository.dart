import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/admin/models/user_response.dart';
import 'package:image_picker/image_picker.dart';
import '../configs/app_config.dart';
import 'package:http/http.dart' as http;

class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException(this.message);
}

class UserRepository {
  final Dio _dio = Dio(
    BaseOptions(
      method: 'GET',
      baseUrl: AppConfigs.baseUrl,
      contentType: 'application/json',
    ),
  );

  Future<Response> _performRequest(
    String endpoint, {
    required String clientId,
    required String token,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String method = 'GET',
  }) async {
    try {
      final response = await _dio.request(endpoint,
          queryParameters: queryParameters,
          options: Options(
            headers: {'Authorization': token, 'x-client-id': clientId},
            method: method,
          ),
          data: data);
      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw Exception('No internet');
      } else if (e.response?.statusCode == 401) {
        throw TokenExpiredException('Token expired');
      } else {
        throw Exception('Unknown error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // API getUserList với phương thức _performRequest tái sử dụng
  Future<UserResponse> getUserList(
      String clientId, String token, String role, int page, int limit) async {
    final response = await _performRequest(
      ApiUrls.getTeacherOrStudentList,
      clientId: clientId,
      token: token,
      queryParameters: {'role': role, 'page': page, 'limit': limit},
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(response.data);
    } else {
      throw Exception('Load list user failed: ${response.statusMessage}');
    }
  }

  // API searchUser với phương thức _performRequest tái sử dụng
  Future<UserResponse> searchUser(
      String clientId, String token, String query, int page, int limit) async {
    final response = await _performRequest(
      ApiUrls.searchUser,
      clientId: clientId,
      token: token,
      queryParameters: {'query': query, 'page': page, 'limit': limit},
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(response.data);
    } else {
      throw Exception('Search user failed: ${response.statusMessage}');
    }
  }

  // API deleteUser với phương thức _performRequest tái sử dụng
  Future<bool> deleteUser(String clientId, String token, String userId) async {
    final response = await _performRequest(
      ApiUrls.deleteUser(userId),
      clientId: clientId,
      token: token,
      method: 'DELETE',
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Delete user failed: ${response.statusMessage}');
    }
  }

  Future<bool> updateUser(String clientId, String token, User user) async {
    final response = await _performRequest(ApiUrls.updateUser(user.id),
        clientId: clientId, token: token, method: 'PATCH', data: user);

    if (response.statusCode == 200) {
      print('Update successfully');
      // final updateResponse = UpdateUserResponse.fromJson(response.data);
      // print('Status code: ${updateResponse.status}');
      return true;
    } else {
      throw Exception('Update failed: ${response.statusMessage}');
    }
  }

  Future<String> uploadAvatarToCloudinary(File file) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/ds9p3qpj3/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['api_key'] = '359193549352628'
        ..fields['upload_preset'] = 'cbmkpvcw'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      print('Sending request to Cloudinary...');
      final response = await request.send();
      print('Received response with status code: ${response.statusCode}');

      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      print('Response body: $responseString');

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(responseString);
        final url = jsonMap['url'] as String;
        print('Image uploaded successfully.URL: $url');
        return url;
      } else {
        throw Exception('Failed to upload image: Status code ${response.statusCode}, Response: $responseString');
      }
    } catch (e) {
      print('Error in uploadAvatarToCloudinary: $e');
      rethrow;
    }
  }
}
