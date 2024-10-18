import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'package:exam_guardian/utils/share_preference/token_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
      final clientRole = await _tokenStorage.getClientRole();

      // Kiểm tra nếu accessToken đã hết hạn
      if (accessToken != null && JwtDecoder.isExpired(accessToken)) {
        // Xử lý token hết hạn, ví dụ: yêu cầu refresh token, hoặc đăng xuất
        print("Access token đã hết hạn.");
        // Có thể emit một trạng thái khác hoặc xử lý làm mới token
        await _tokenStorage.clearTokens();
        emit(state.copyWith(accessToken: null, refreshToken: null, clientId: null));
      } else {
        emit(state.copyWith(
          accessToken: accessToken,
          refreshToken: refreshToken,
          clientId: clientId,
          clientRole: clientRole,
          loading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(loading: false));
    }
  }

  // Xóa tokens khi đăng xuất
  Future<void> clearTokens() async {
    await _tokenStorage.clearTokens();
    emit(state.copyWith(accessToken: null, refreshToken: null, clientId: null));
  }
}
