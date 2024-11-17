import '../utils/exceptions/token_exceptions.dart';

abstract class BaseRepository {
  Future<T> handleApiRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on TokenExpiredException {
      rethrow; // Để Cubit xử lý
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }
} 