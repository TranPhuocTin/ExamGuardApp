import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/app_config.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/login/models/login_request.dart';
import 'package:exam_guardian/share_preference/shared_preference.dart';
import 'package:exam_guardian/features/login/models/login_response.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
        baseUrl: AppConfigs.baseUrl,
        method: 'POST',
        contentType: 'application/json'),
  );

  final TokenStorage _tokenStorage = TokenStorage();

  Future<LoginResponse> login (String username, String password) async {
    try{
      final data = LoginRequest(usernameOrEmail: username, password: password);
      final response = await _dio.post('${AppConfigs.baseUrl}${ApiUrls.login}', data: data);

      if(response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);

        await _tokenStorage.saveAccessToken(loginResponse.metadata.tokens.accessToken);
        await _tokenStorage.saveRefreshToken(loginResponse.metadata.tokens.refreshToken);
        await _tokenStorage.saveClientId(loginResponse.metadata.user.id);
        print(loginResponse.message);
        return loginResponse;
      }
      else {
        throw Exception('Đăng nhập thất bại: ${response.statusMessage}');
      }
    }
    catch(e) {
      throw Exception('Lỗi khi đăng nhập: $e');
    }
  }

  // Hàm để lấy thông tin người dùng
  Future<User> getUserInfo() async {
    try {
      // Lấy accessToken từ TokenStorage
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) {
        throw Exception('Chưa có token. Vui lòng đăng nhập lại.');
      }

      // Gửi yêu cầu GET để lấy thông tin người dùng
      final response = await _dio.get(
        'https://api.example.com/user', // Thay URL bằng API của bạn
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      // Parse dữ liệu phản hồi thành đối tượng User
      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      } else {
        throw Exception('Không thể lấy thông tin người dùng');
      }
    } catch (error) {
      throw Exception('Lỗi khi lấy thông tin người dùng: $error');
    }
  }
}
