import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/app_config.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/teacher/models/exam_response.dart';

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException(this.message);
}

class ExamRepository {
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
        data: data,
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

  Future<ExamResponse> getInProgressExams(String clientId, String token, {String? status, int page = 1}) async {
    final response = await _performRequest(
      ApiUrls.getExamList,
      clientId: clientId,
      token: token,
      queryParameters: {'status': status, 'page': page},
    );

    if (response.statusCode == 200) {
      return ExamResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to load in-progress exams: ${response.statusMessage}');
    }
  }
}
