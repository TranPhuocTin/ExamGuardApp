import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/admin/models/user_response.dart';
import '../configs/app_config.dart';

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
      final response = await _dio.request(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: {'Authorization': token, 'x-client-id': clientId},
          method: method,
        ),
        data: data
      );
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

  Map<String, dynamic> updateUserInfo = {
    "_id": "6703350b98fa3db1b36c190d",
    "username": "allensheila",
    "name": "Gregory Cherry",
    "email": "amandahampton@example.org",
    "role": "STUDENT",
    "avatar": "",
    "gender": "FEMALE",
    "ssn": 6262806739,
    "dob": "1994-07-01T00:00:00.000Z",
    "address": "61690 Richardson Station Apt. 791\nWest John, PA 91842",
    "phone_number": "(802)200-6513x78173",
    "status": "ACTIVE",
    "createdAt": "2024-10-07T01:10:35.017Z",
    "updatedAt": "2024-10-07T01:10:35.017Z"
  };

  Future<bool> updateUser(String clientId, String token, User user) async {
    final response = await _performRequest(
      ApiUrls.updateUser(user.id),
      clientId: clientId,
      token: token,
      method: 'PATCH',
      data: user
    );

    if (response.statusCode == 200) {
      print('Update successfully');
      // final updateResponse = UpdateUserResponse.fromJson(response.data);
      // print('Status code: ${updateResponse.status}');
      return true;
    } else {
      throw Exception('Update failed: ${response.statusMessage}');
    }
  }
}
