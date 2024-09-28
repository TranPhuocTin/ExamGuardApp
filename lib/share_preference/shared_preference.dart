import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';

  // Lưu trữ accessToken
  Future<void> saveAccessToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
  }

  // Lưu trữ refreshToken
  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Lấy accessToken
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  // Lấy refreshToken
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  // Xóa cả accessToken và refreshToken khi đăng xuất
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }
}
