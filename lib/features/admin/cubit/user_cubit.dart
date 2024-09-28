import 'package:bloc/bloc.dart';
import 'package:exam_guardian/data/user_repository.dart';
import 'package:exam_guardian/features/admin/cubit/user_state.dart';
import 'package:exam_guardian/share_preference/shared_preference.dart';
import '../models/user_response.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  int _page = 1;
  static const int _limit = 20;

  UserCubit(this._userRepository) : super(const UserState());

  Future<void> fetchUsers(String role) async {
    if (state.isLoading || state.hasReachedMax) return;

    emit(state.copyWith(isLoading: true));

    try {
      TokenStorage tokenStorage = TokenStorage();
      final clientId = await tokenStorage.getAccessToken();
      if (clientId != null) {
        final UserResponse response =
            await _userRepository.getUserList(clientId, role, _page, _limit);
        final List<User> users = response.metadata;

        final bool isLastPage = users.length < _limit;

        if (isLastPage) {
          emit(state.copyWith(
            users: [...state.users, ...users],
            isLoading: false,
            hasReachedMax: true,
          ));
        } else {
          _page++;
          emit(state.copyWith(
            users: [...state.users, ...users],
            isLoading: false,
          ));
        }
      }
      else print('The client id was null');
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void reset() {
    _page = 1;
    emit(const UserState());
  }
}
