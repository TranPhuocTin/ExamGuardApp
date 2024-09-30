import 'package:exam_guardian/share_preference/shared_preference.dart';
import 'package:exam_guardian/share_preference/token_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TokenCubit extends Cubit<TokenState> {
  final TokenStorage _tokenStorage;

  TokenCubit(this._tokenStorage) : super(const TokenState());

  // Lấy accessToken, refreshToken, và clientId từ SharedPreferences
  Future<void> loadTokens() async {
    emit(state.copyWith(loading: true));
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      final refreshToken = await _tokenStorage.getRefreshToken();
      final clientId = await _tokenStorage.getClientId();
      emit(state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        clientId: clientId,
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  // Lưu accessToken
  Future<void> saveAccessToken(String accessToken) async {
    await _tokenStorage.saveAccessToken(accessToken);
    emit(state.copyWith(accessToken: accessToken));
  }

  // Lưu refreshToken
  Future<void> saveRefreshToken(String refreshToken) async {
    await _tokenStorage.saveRefreshToken(refreshToken);
    emit(state.copyWith(refreshToken: refreshToken));
  }

  // Lưu clientId
  Future<void> saveClientId(String clientId) async {
    await _tokenStorage.saveClientId(clientId);
    emit(state.copyWith(clientId: clientId));
  }

  // Xóa tokens khi đăng xuất
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
    emit(state.copyWith(accessToken: null, refreshToken: null, clientId: null));
  }
}
