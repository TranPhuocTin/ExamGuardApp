import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/admin/models/user_response.dart';

import '../configs/dio_config.dart';

class UserRepository {
  Future<UserResponse> getUserList(
      String clientId, String token, String role, int page, int limit) async {
    final response = await DioClient.performRequest(
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

  Future<UserResponse> searchUser(
      String clientId, String token, String query, int page, int limit) async {
    final response = await DioClient.performRequest(
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

  Future<bool> deleteUser(String clientId, String token, String userId) async {
    final response = await DioClient.performRequest(
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
    final response = await DioClient.performRequest(
      ApiUrls.updateUser(user.id),
      clientId: clientId,
      token: token,
      method: 'PATCH',
      data: user,
    );

    if (response.statusCode == 200) {
      print('Update successfully');
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
      final dio = Dio();
      final response = await dio.post(
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
      String publicId = extractPublicId(imageUrl);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String apiSecret = 'S8eSNXqDpdUMCp7ZvyMPcSlow9k';
      String apiKey = '359193549352628';

      String signatureString = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      String signature = sha1.convert(utf8.encode(signatureString)).toString();

      print('Sending delete request to Cloudinary for public ID: $publicId');

      final dio = Dio();
      final response = await dio.post(
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
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    final uploadIndex = pathSegments.indexOf('upload');
    final relevantSegments = pathSegments.sublist(uploadIndex + 1);
    if (relevantSegments.first.startsWith('v')) {
      relevantSegments.removeAt(0);
    }
    final lastSegment = relevantSegments.last;
    final lastSegmentWithoutExtension = lastSegment.split('.').first;
    relevantSegments[relevantSegments.length - 1] = lastSegmentWithoutExtension;
    return relevantSegments.join('/');
  }
}
