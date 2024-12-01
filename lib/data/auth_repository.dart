import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/app_config.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/login/models/login_request.dart';
import 'package:exam_guardian/features/login/models/login_response.dart';
import '../utils/exceptions/api_exceptions.dart';
import '../utils/share_preference/shared_preference.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio}) 
    : _dio = dio ?? Dio(BaseOptions(
        baseUrl: AppConfigs.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ));

  final TokenStorage _tokenStorage = TokenStorage();

  Future<LoginResponse> login(String username, String password) async {
    try {
      final data = LoginRequest(usernameOrEmail: username, password: password);
      final response = await _dio.post(ApiUrls.login, data: data);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Lưu tokens
        await _tokenStorage.saveAccessToken(loginResponse.metadata.tokens.accessToken);
        await _tokenStorage.saveRefreshToken(loginResponse.metadata.tokens.refreshToken);
        await _tokenStorage.saveClientId(loginResponse.metadata.user.id);
        await _tokenStorage.saveClientRole(loginResponse.metadata.user.role);
        
        final userJson = loginResponse.metadata.user.toJson();
        await _tokenStorage.saveUser(userJson);

        return loginResponse;
      } else {
        throw ApiException(message: 'Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final clientId = await _tokenStorage.getClientId();
      
      if (token == null || clientId == null) {
        throw ApiException(message: 'Token or ClientId not found');
      }

      final response = await _dio.post(
        ApiUrls.logout,
        options: Options(
          headers: {
            'Authorization': token,
            'x-client-id': clientId
          },
        ),
      );

      if (response.statusCode == 200) {
        await _tokenStorage.clearAll();
      } else {
        throw ApiException(message: 'Logout failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // Hàm để lấy thông tin người dùng

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiUrls.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw ApiException(message: 'Failed to send reset link');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await _dio.post(
        ApiUrls.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(message: 'Failed to reset password');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
