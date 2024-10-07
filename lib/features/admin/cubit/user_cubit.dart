import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/user_repository.dart';
import '../../../utils/share_preference/shared_preference.dart';
import '../models/user_response.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  UserCubit(this._userRepository) : super(const UserState());

  Future<void> preloadData() async {
    await Future.wait([
      fetchUsers('TEACHER', isPreloading: true),
      fetchUsers('STUDENT', isPreloading: true),
    ]);
  }

  Future<void> fetchUsers(String role, {int? page, int limit = 5, bool isPreloading = false, bool forceRefresh = false}) async {
    TokenStorage tokenStorage = TokenStorage();

    try {
      final token = await tokenStorage.getAccessToken();
      final clientId = await tokenStorage.getClientId();
      if (token == null || clientId == null) {
        throw Exception('Token or clientId in fetchUsers function have a null value');
      }

      final currentPage = forceRefresh ? 1 : (page ?? (role == 'TEACHER' ? state.currentPageTeachers : state.currentPageStudents));
      print('Fetching $role users for page: $currentPage');

      if (!isPreloading) {
        emit(state.copyWith(
          isLoadingTeachers: role == 'TEACHER',
          isLoadingStudents: role == 'STUDENT',
          isRefreshing: true, // New flag to trigger UI update
        ));
      }

      final response = await _userRepository.getUserList(clientId, token, role, currentPage, limit);
      final newUsers = (currentPage == 1 || forceRefresh)
          ? response.metadata.users
          : [
        ...(role == 'TEACHER' ? state.teachers : state.students),
        ...response.metadata.users
      ];

      final hasReachedMax = response.metadata.totalPages == 0 || currentPage >= response.metadata.totalPages;

      if (role == 'TEACHER') {
        emit(state.copyWith(
          teachers: newUsers,
          currentPageTeachers: currentPage + 1,
          totalPagesTeachers: response.metadata.totalPages,
          hasReachedMaxTeachers: hasReachedMax,
          isLoadingTeachers: false,
          isLoadingMoreTeachers: false,
          isRefreshing: false,
        ));
      } else {
        emit(state.copyWith(
          students: newUsers,
          currentPageStudents: currentPage + 1,
          totalPagesStudents: response.metadata.totalPages,
          hasReachedMaxStudents: hasReachedMax,
          isLoadingStudents: false,
          isLoadingMoreStudents: false,
          isRefreshing: false,
        ));
      }
    } catch (e) {
      print('Error fetching users: $e');
      emit(state.copyWith(
        errorTeachers: role == 'TEACHER' ? e.toString() : null,
        errorStudents: role == 'STUDENT' ? e.toString() : null,
        isLoadingTeachers: false,
        isLoadingStudents: false,
        isLoadingMoreTeachers: false,
        isLoadingMoreStudents: false,
        isRefreshing: false,
      ));
    }
  }

  Future<void> _handleTokenExpiration(String message) async {
    // Clear token from storage
    TokenStorage tokenStorage = TokenStorage();
    await tokenStorage.clearTokens();

    // Emit new state with error message and cleared data
    emit(UserState(
      errorTeachers: message,
      errorStudents: message,
    ));
  }

  void switchTab(String role) {
    // No need to change state here, as we're now maintaining separate lists
  }

  Future<void> searchUsers(String query, String role, {int? page, int limit = 5}) async {
    TokenStorage tokenStorage = TokenStorage();

    try {
      final token = await tokenStorage.getAccessToken();
      final clientId = await tokenStorage.getClientId();
      if (token == null || clientId == null) {
        throw Exception(
            'Token or clientId in searchUsers function have a null value');
      }

      final currentPage = page ?? 1;

      if (currentPage == 1) {
        emit(state.copyWith(isSearching: true, searchQuery: query));
      }

      final response = await _userRepository.searchUser(
          clientId, token, query, currentPage, limit);
      final newUsers = (currentPage == 1)
          ? response.metadata.users
          : [
        ...(role == 'TEACHER' ? state.teachers : state.students),
        ...response.metadata.users
      ];

      final hasReachedMax = currentPage >= response.metadata.totalPages;

      if (role == 'TEACHER') {
        emit(state.copyWith(
          teachers: newUsers,
          currentPageTeachers: currentPage,
          totalPagesTeachers: response.metadata.totalPages,
          hasReachedMaxTeachers: hasReachedMax,
          isLoadingTeachers: false,
          isLoadingMoreTeachers: false,
          isSearching: true,
        ));
      } else {
        emit(state.copyWith(
          students: newUsers,
          currentPageStudents: currentPage,
          totalPagesStudents: response.metadata.totalPages,
          hasReachedMaxStudents: hasReachedMax,
          isLoadingStudents: false,
          isLoadingMoreStudents: false,
          isSearching: true,
        ));
      }
    } on TokenExpiredException catch (e) {
      await _handleTokenExpiration(e.message);
    } catch (e) {
      print('Error searching users: $e');
      emit(state.copyWith(
          errorTeachers: e.toString(),
          errorStudents: e.toString(),
          isLoadingTeachers: false,
          isLoadingStudents: false,
          isLoadingMoreTeachers: false,
          isLoadingMoreStudents: false));
    }
  }

  void toggleEditing() {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  Future<void> deleteUser(String userId, String role) async {

    try {
      TokenStorage tokenStorage = TokenStorage();
      final currentStudents = state.students;
      final currentTeachers = state.teachers;
      emit(state.copyWith(
          isLoadingTeachers: role == 'TEACHER',
          isLoadingStudents: role == 'STUDENT',
          deleteSuccess: false,
          errorTeachers: null,
          errorStudents: null
      ));

      final token = await tokenStorage.getAccessToken();
      final clientId = await tokenStorage.getClientId();
      if (token == null || clientId == null) {
        throw Exception('Token or clientId null in deleteUser');
      }

      final deleteResponse = await _userRepository.deleteUser(clientId, token, userId);

      if (deleteResponse) {
        if (role == 'TEACHER') {
          print("Teachers before filter: ${state.teachers}"); // In ra danh sách teachers trước khi lọc
          final updatedTeachers = state.teachers.where((user) => user.id != userId).toList();
          print("Teachers after filter: $updatedTeachers"); // In ra danh sách teachers sau khi lọc
          emit(state.copyWith(teachers: updatedTeachers, /* ... */));
        } else {
          print("Students before filter: ${state.students}"); // In ra danh sách students trước khi lọc
          final updatedStudents = state.students.where((user) => user.id != userId).toList();
          print("Students after filter: $updatedStudents"); // In ra danh sách students sau khi lọc
          emit(state.copyWith(students: updatedStudents, /* ... */));
        }
      } else {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingTeachers: false,
        isLoadingStudents: false,
        deleteSuccess: false,
        errorTeachers: role == 'TEACHER' ? e.toString() : null,
        errorStudents: role == 'STUDENT' ? e.toString() : null,
      ));
    }
  }

  Future<void> updateUser(User updateUser) async {
    TokenStorage tokenStorage = TokenStorage();

    try {
      final token = await tokenStorage.getAccessToken();
      final clientId = await tokenStorage.getClientId();
      if (token == null || clientId == null) {
        throw Exception(
            'Token or clientId in updateUser function have a null value');
      }

      emit(state.copyWith(
          isLoadingTeachers: updateUser.role == 'TEACHER',
          isLoadingStudents: updateUser.role == 'STUDENT'));

      await _userRepository.updateUser(clientId, token, updateUser);

      final updatedUsers = updateUser.role == 'TEACHER'
          ? state.teachers.map((user) => user.id == updateUser.id ? updateUser : user).toList()
          : state.students.map((user) => user.id == updateUser.id ? updateUser : user).toList();

      emit(state.copyWith(
        teachers: updateUser.role == 'TEACHER' ? updatedUsers : state.teachers,
        students: updateUser.role == 'STUDENT' ? updatedUsers : state.students,
        isLoadingTeachers: false,
        isLoadingStudents: false,
        updateSuccess: true,
      ));
    } on TokenExpiredException catch (e) {
      await _handleTokenExpiration(e.message);
    } catch (e) {
      print('Error update users: $e');
      emit(state.copyWith(
        errorTeachers: updateUser.role == 'TEACHER' ? e.toString() : null,
        errorStudents: updateUser.role == 'STUDENT' ? e.toString() : null,
        isLoadingTeachers: false,
        isLoadingStudents: false,
        updateSuccess: false,
      ));
    }
  }

  void resetState() {
    print('Resetting state');
    emit(UserState());
  }
}