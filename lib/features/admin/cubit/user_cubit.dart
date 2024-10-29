  import 'dart:io';

  import 'package:cloudinary_public/cloudinary_public.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:image_picker/image_picker.dart';
  import '../../../data/user_repository.dart';
  import '../../../utils/share_preference/shared_preference.dart';
  import '../models/user_response.dart';
  import 'user_state.dart';

  class UserCubit extends Cubit<UserState> {
    final UserRepository _userRepository;

    UserCubit(this._userRepository) : super(const UserState());

    void setAvatarLoading(bool isLoading) {
      if (state.isAvatarLoading != isLoading) {
        emit(state.copyWith(isAvatarLoading: isLoading));
      }
    }

    void clearSelectedAvatar(String role, String id) {
      if (role == 'TEACHER') {
        List<User> updatedTeachers = state.teachers.map((teacher) {
          if (teacher.id == id) {
            return teacher.copyWith(selectedAvatarFile: null, tempAvatarUrl: null);
          }
          return teacher;
        }).toList();
        emit(state.copyWith(teachers: updatedTeachers));
      } else if (role == 'STUDENT') {
        List<User> updatedStudents = state.students.map((student) {
          if (student.id == id) {
            return student.copyWith(selectedAvatarFile: null, tempAvatarUrl: null);
          }
          return student;
        }).toList();
        emit(state.copyWith(students: updatedStudents));
      }
    }

    Future<void> preloadData() async {
      await Future.wait([
        fetchUsers('TEACHER', isPreloading: true),
        fetchUsers('STUDENT', isPreloading: true),
      ]);
    }

    Future<void> fetchUsers(String role, {int? page, int limit = 10, bool isPreloading = false, bool forceRefresh = false}) async {
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
            isRefreshing: forceRefresh,
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
            currentPageTeachers: currentPage,
            totalPagesTeachers: response.metadata.totalPages,
            hasReachedMaxTeachers: hasReachedMax,
            isLoadingTeachers: false,
            isLoadingMoreTeachers: false,
            isRefreshing: false,
          ));
        } else {
          emit(state.copyWith(
            students: newUsers,
            currentPageStudents: currentPage,
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
      await tokenStorage.clearAll();

      // Emit new state with error message and cleared data
      emit(UserState(
        errorTeachers: message,
        errorStudents: message,
      ));
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

    Future<String?> uploadAvatar(String role, String userId, File? image) async {
      emit(state.copyWith(isUploading: true));
      try {
        if(image != null) {
          final updateResponse = await _userRepository.uploadAvatarToCloudinary(image);
          final newAvatarUrl = updateResponse['url'] as String;
          if (role == 'TEACHER') {
            final updatedTeachers = state.teachers.map((teacher) {
              if (teacher.id == userId) {
                return teacher.copyWith(avatar: newAvatarUrl, tempAvatarUrl: null);
              }
              return teacher;
            }).toList();
            emit(state.copyWith(
              teachers: updatedTeachers,
              isUploading: false,
            ));
          } else if (role == 'STUDENT') {
            final updatedStudents = state.students.map((student) {
              if (student.id == userId) {
                return student.copyWith(avatar: newAvatarUrl, tempAvatarUrl: null);
              }
              return student;
            }).toList();
            emit(state.copyWith(
              students: updatedStudents,
              isUploading: false,
            ));
          }

          // Clear the selected avatar file after successful upload
          clearSelectedAvatar(role, userId);
          return newAvatarUrl;
        }
      } catch (e) {
        emit(state.copyWith(isUploading: false, errorTeachers: e.toString()));
      }
    }

    Future<bool> deleteAvatar(String publicId) async {
      return await _userRepository.deleteCloudinaryImage(publicId);
    }

    Future<void> updateUser(User updatedUser) async {
      TokenStorage tokenStorage = TokenStorage();
      try {
        final token = await tokenStorage.getAccessToken();
        final clientId = await tokenStorage.getClientId();
        if (token == null || clientId == null) {
          throw Exception('Token or clientId in updateUser function have a null value');
        }

        emit(state.copyWith(
          isUpdating: true,
          updateSuccess: false,
          errorTeachers: null,
          errorStudents: null,
        ));

        // String? newAvatarUrl;
        // if (state.selectedAvatarFile != null) {
        //   // Upload the new avatar if one is selected
        //   final uploadResponse = await _userRepository.uploadAvatarToCloudinary(state.selectedAvatarFile!);
        //   newAvatarUrl = uploadResponse['url'] as String;
        //   updatedUser = updatedUser.copyWith(avatar: newAvatarUrl);
        // }

        // Perform the update on the server
        final bool success = await _userRepository.updateUser(clientId, token, updatedUser);
        // final deleteStatus = await _userRepository.deleteCloudinaryImage('mov3iudjdgxwyqc1vj4x');
        // print('delete status: $deleteStatus');
        if (success) {
          // Update local state
          List<User> updatedTeachers = List.from(state.teachers);
          List<User> updatedStudents = List.from(state.students);

          if (updatedUser.role == 'TEACHER') {
            final index = updatedTeachers.indexWhere((teacher) => teacher.id == updatedUser.id);
            if (index != -1) {
              updatedTeachers[index] = updatedUser;
            } else {
              updatedTeachers.add(updatedUser);
            }
          } else if (updatedUser.role == 'STUDENT') {
            final index = updatedStudents.indexWhere((student) => student.id == updatedUser.id);
            if (index != -1) {
              updatedStudents[index] = updatedUser;
            } else {
              updatedStudents.add(updatedUser);
            }
          }

          emit(state.copyWith(
            teachers: updatedTeachers,
            students: updatedStudents,
            isUpdating: false,
            updateSuccess: true,
            // avatarUrl: newAvatarUrl ?? state.avatarUrl,
            selectedAvatarFile: null, // Clear the selected avatar file after successful update
          ));
        } else {
          throw Exception('Failed to update user.');
        }
      } on TokenExpiredException catch (e) {
        await _handleTokenExpiration(e.message);
      } catch (e) {
        print('Error updating user: $e');
        emit(state.copyWith(
          errorTeachers: updatedUser.role == 'TEACHER' ? e.toString() : null,
          errorStudents: updatedUser.role == 'STUDENT' ? e.toString() : null,
          isUpdating: false,
          updateSuccess: false,
        ));
      }
    }

    void resetState() {
      print('Resetting state');
      emit(UserState());
    }
  }
