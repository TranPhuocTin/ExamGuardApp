import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/admin/models/user_response.dart';
import 'package:exam_guardian/share_preference/shared_preference.dart';

import '../configs/app_config.dart';

class UserRepository {
  final _token = TokenStorage();
  final Dio _dio = Dio(
    BaseOptions(
      method: 'GET',
      baseUrl: AppConfigs.baseUrl,
      contentType: 'application/json',
    ),
  );

  Future<UserResponse> getUserList(String clientId, String role, int page, int limit) async {
    try {
      final token = await _token.getAccessToken();
      if (_token != null) {
        final url = '${AppConfigs.baseUrl}${ApiUrls.getTeacherOrStudentList}';
        final response = await _dio.get(
          url,
          queryParameters: {
            'role': role,
            'page': page,
            'limit': limit,
          },
          options: Options(
            headers: {'Authorization': '$token', 'x-client-id': clientId},
          ),
        );

        if (response.statusCode == 200) {
          final listUser = UserResponse.fromJson(response.data);
          return listUser;
        } else {
          throw Exception('Load list user failed: ${response.statusMessage}');
        }
      } else {
        throw Exception('Token null');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User> findUserById(String clientId, String userId) async {
    try {
      final token = await _token.getAccessToken();
      final url = '${AppConfigs.baseUrl}${ApiUrls.findUserById(userId)}';
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': '$token',
            'x-client-id': clientId
          },
        ),
      );

      if(response.statusCode == 200) {
        final user = User.fromJson(response.data['metadata']);
        return user;
      }
      else{
        throw Exception('Status code diffirent 200');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  
}
