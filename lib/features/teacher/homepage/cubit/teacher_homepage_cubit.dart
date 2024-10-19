import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/data/exam_repository.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import '../../models/exam.dart';
import 'teacher_homepage_state.dart';
import 'dart:async';

class TeacherHomepageCubit extends Cubit<TeacherHomepageState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  Timer? _debounce;

  TeacherHomepageCubit(this._examRepository, this._tokenStorage)
      : super(TeacherHomepageInitial());

  Future<void> loadInProgressExams({bool forceReload = false}) async {
    if (state is TeacherHomepageLoading) return;

    final currentState = state;
    List<Exam> oldExams = [];
    int currentPage = 1;
    bool isSearching = false;
    String searchQuery = '';

    if (currentState is TeacherHomepageLoaded) {
      if (forceReload) {
        currentPage = 1;
      } else {
        oldExams = currentState.exams;
        currentPage = currentState.currentPage;
        isSearching = currentState.isSearching;
        searchQuery = currentState.searchQuery;
      }
    }

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(TeacherHomepageError('Authentication information is missing'));
        return;
      }
      final status = 'In Progress';
      final examResponse = isSearching
          ? await _examRepository.searchExams(clientId, token, searchQuery,
              page: currentPage)
          : await _examRepository.getExams(clientId, token,
              page: currentPage, status: status);

      final newExams = forceReload
          ? examResponse.metadata.exams
          : [...oldExams, ...examResponse.metadata.exams];
      final hasReachedMax = examResponse.metadata.exams.isEmpty;

      emit(TeacherHomepageLoaded(
        newExams,
        hasReachedMax: hasReachedMax,
        currentPage: currentPage + 1,
        isSearching: isSearching,
        searchQuery: searchQuery,
      ));
    } on TokenExpiredException {
      emit(TeacherHomepageError('Session expired. Please log in again.'));
    } catch (e) {
      emit(TeacherHomepageError('Failed to load exams: $e'));
    }
  }

  void searchExams(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        await loadInProgressExams(forceReload: true);
      } else {
        emit(TeacherHomepageLoading([]));
        try {
          final clientId = await _tokenStorage.getClientId();
          final token = await _tokenStorage.getAccessToken();
          if (clientId == null || token == null) {
            emit(TeacherHomepageError('Authentication information is missing'));
            return;
          }

          final examResponse =
              await _examRepository.searchExams(clientId, token, query);
          final inProgressExam = examResponse.metadata.exams
              .where((exam) => exam.status == 'In Progress')
              .toList();
          emit(TeacherHomepageLoaded(
            inProgressExam,
            hasReachedMax: true,
            currentPage: 1,
            isSearching: true,
            searchQuery: query,
          ));
        } catch (e) {
          emit(TeacherHomepageError('Failed to search exams: $e'));
        }
      }
    });
  }

  void resetSearch() {
    loadInProgressExams(forceReload: true);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
