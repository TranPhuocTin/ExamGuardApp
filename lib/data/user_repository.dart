import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/admin/models/user_response.dart';
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

  Future<dynamic> uploadAvatarToCloudinary(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': 'cbmkpvcw',
      });

      print('Sending request to Cloudinary...');
      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/ds9p3qpj3/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      print('Received response with status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final url = response.data['url'] as String;
        print('Image uploaded successfully. URL: $url');
        return response.data;
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in uploadAvatarToCloudinary: $e');
      rethrow;
    }
  }
  Future<bool> deleteCloudinaryImage(String imageUrl) async {
    try {
      // Tạo chữ ký cho yêu cầu
      String publicId = extractPublicId(imageUrl);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String apiSecret = 'S8eSNXqDpdUMCp7ZvyMPcSlow9k';
      String apiKey = '359193549352628';

      // Tạo chuỗi để ký
      String signatureString = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

      // Tạo chữ ký SHA1
      String signature = sha1.convert(utf8.encode(signatureString)).toString();

      print('Sending delete request to Cloudinary for public ID: $publicId');

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/ds9p3qpj3/image/destroy',
        data: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      print('Received delete response with status code: ${response.statusCode}');
      print('Delete response data: ${response.data}');

      if (response.statusCode == 200) {
        print('Image deleted successfully');
        return true;
      } else {
        throw Exception('Failed to delete image: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in deleteCloudinaryImage: $e');
      rethrow;
    }
  }

  String extractPublicId(String imageUrl) {
    // Phân tích URL
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;

    // Tìm index của phần tử 'upload' trong pathSegments
    final uploadIndex = pathSegments.indexOf('upload');

    // Lấy tất cả các phần sau 'upload', bỏ qua phiên bản và phần mở rộng
    final relevantSegments = pathSegments.sublist(uploadIndex + 1);
    if (relevantSegments.first.startsWith('v')) {
      relevantSegments.removeAt(0);  // Loại bỏ phần tử phiên bản nếu có
    }

    // Loại bỏ phần mở rộng file từ phần tử cuối cùng
    final lastSegment = relevantSegments.last;
    final lastSegmentWithoutExtension = lastSegment.split('.').first;
    relevantSegments[relevantSegments.length - 1] = lastSegmentWithoutExtension;

    // Kết hợp các phần còn lại để tạo public ID
    return relevantSegments.join('/');
  }

}
