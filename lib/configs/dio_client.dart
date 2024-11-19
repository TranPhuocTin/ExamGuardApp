import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/app_config.dart';

import '../utils/exceptions/token_exceptions.dart';
import '../utils/exceptions/exam_exceptions.dart';

class DioClient {
  static Dio getInstance() {
    return Dio(
      BaseOptions(
        method: 'GET',
        baseUrl: AppConfigs.baseUrl,
        contentType: 'application/json',
      ),
    );
  }

  static Future<Response> performRequest(
    String endpoint, {
    required String clientId,
    required String token,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String method = 'GET',
  }) async {
    final dio = getInstance();
    
    try {
      final response = await dio.request(
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
        print('Token expired status code: ${e.response?.statusCode}');
        throw TokenExpiredException('Token expired');
      } else if(e.response?.statusCode == 403) {
        throw ExamAlreadyTakenException('You already completed this exam');
      }
      else {
        throw Exception('Unknown error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
