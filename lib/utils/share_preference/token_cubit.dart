import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'package:exam_guardian/utils/share_preference/token_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenCubit extends Cubit<TokenState> {
  final TokenStorage _tokenStorage;

  TokenCubit(this._tokenStorage) : super(const TokenState());

  // Lấy accessToken, refreshToken, và clientId từ SharedPreferences
  Future<void> loadTokens() async {
    print('🔄 TokenCubit: Đang load tokens...');
    emit(state.copyWith(loading: true));
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      final refreshToken = await _tokenStorage.getRefreshToken();
      final clientId = await _tokenStorage.getClientId();
      final clientRole = await _tokenStorage.getClientRole();

      print('📝 TokenCubit - Token hiện tại:');
      print('- AccessToken: ${accessToken?.substring(0, 20)}... (truncated)');
      print('- ClientId: $clientId');
      print('- Role: $clientRole');
      
      emit(state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        clientId: clientId,
        clientRole: clientRole,
        loading: false,
      ));
    } catch (e) {
      print('❌ TokenCubit - Lỗi khi load tokens: $e');
      emit(state.copyWith(loading: false));
    }
  }

  // Xóa tokens khi đăng xuất
  Future<void> clearTokens() async {
    print('🗑️ TokenCubit: Đang xóa tokens...');
    await _tokenStorage.clearAll();
    emit(state.copyWith(
      accessToken: null, 
      refreshToken: null, 
      clientId: null, 
      clientRole: null,
    ));
    print('✅ TokenCubit: Đã xóa tokens thành công');
  }

  void handleTokenError(Object error) {
    print('🔄 TokenCubit: Handling token error: $error');
    emit(TokenState(
          accessToken: null,
          refreshToken: null,
          clientId: null,
      error: error,
    ));
    print('✅ TokenCubit: State updated with error');
  }


}
