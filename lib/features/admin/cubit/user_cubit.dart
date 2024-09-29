import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/user_repository.dart';
import '../models/user_response.dart';
import 'package:exam_guardian/share_preference/shared_preference.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;
  UserCubit(this._userRepository) : super(const UserState());

  Future<void> fetchUsers(String role, {int? page, int limit = 5}) async {
    if (state.hasReachedMax) {
      print('Has reached max, not fetching more');
      return;
    }

    try {
      final currentPage = page ?? state.currentPage;
      print('Fetching users for page: $currentPage');

      if (currentPage == 1) {
        emit(state.copyWith(isLoading: true));
      } else {
        emit(state.copyWith(isLoadingMore: true));
      }

      final response = await _userRepository.getUserList('66f67e068ac04e1a9b553f9a', role, currentPage, limit);
      final newUsers = (currentPage == 1)
          ? response.metadata.users
          : [...state.users, ...response.metadata.users];

      print('Fetched ${response.metadata.users.length} users');
      print('Total users after fetch: ${newUsers.length}');
      print('Total pages: ${response.metadata.totalPages}');

      final hasReachedMax = currentPage >= response.metadata.totalPages;

      emit(state.copyWith(
        users: newUsers,
        isLoading: false,
        isLoadingMore: false,
        currentPage: currentPage,
        totalPages: response.metadata.totalPages,
        hasReachedMax: hasReachedMax,
      ));

      print('Current state after emit:');
      print('Users count: ${state.users.length}');
      print('Current page: ${state.currentPage}');
      print('Has reached max: ${state.hasReachedMax}');
    } catch (e) {
      print('Error fetching users: $e');
      emit(state.copyWith(error: e.toString(), isLoading: false, isLoadingMore: false));
    }
  }

  void resetState() {
    print('Resetting state');
    emit(UserState());
  }
}
