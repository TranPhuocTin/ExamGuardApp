import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String adminClientId = 'clientId';
  static const String clientRole = 'clientRole';

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

  Future<void> saveClientId(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(adminClientId, clientId);
  }

  Future<void> saveClientRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(clientRole, role);
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

  Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(adminClientId);
  }

  Future<String?> getClientRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(clientRole);
  }

  // Xóa cả accessToken và refreshToken khi đăng xuất
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(adminClientId);
    await prefs.remove(clientRole);
  }
}
