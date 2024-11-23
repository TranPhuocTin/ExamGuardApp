import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/data/exam_repository.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'dart:async';

import '../../../configs/dio_client.dart';
import '../../../utils/exceptions/token_exceptions.dart';
import '../../../utils/share_preference/token_cubit.dart';
import '../models/exam.dart';
import 'base_homepage_state.dart';

class BaseHomepageCubit extends Cubit<BaseHomepageState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  Timer? _debounce;

  BaseHomepageCubit(this._examRepository, this._tokenStorage, this._tokenCubit)
      : super(HomepageInitial());

  void handleTokenError(TokenExpiredException error) {
    _tokenCubit.handleTokenError(error);
  }

  Future<void> loadInProgressExams({bool forceReload = false}) async {
    if (state is HomepageLoading || isClosed) return;

    final currentState = state;
    List<Exam> oldExams = [];
    int currentPage = 1;
    bool isSearching = false;
    String searchQuery = '';

    if (currentState is HomepageLoaded) {
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
        emit(HomepageError('Authentication information is missing'));
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

      if (!isClosed) {
        emit(HomepageLoaded(
          newExams,
          hasReachedMax: hasReachedMax,
          currentPage: currentPage + 1,
          isSearching: isSearching,
          searchQuery: searchQuery,
        ));
      }
    } catch (e) {
      print('🔄 Caught error in BaseHomepageCubit: $e');
      if (!isClosed) {
        _tokenCubit.handleTokenError(e);
        emit(HomepageError(e.toString()));
      }
    }
  }

  void searchExams(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        await loadInProgressExams(forceReload: true);
      } else {
        emit(HomepageLoading([]));
        try {
          final clientId = await _tokenStorage.getClientId();
          final token = await _tokenStorage.getAccessToken();
          if (clientId == null || token == null) {
            emit(HomepageError('Authentication information is missing'));
            return;
          }

          final examResponse =
              await _examRepository.searchExams(clientId, token, query);
          final inProgressExam = examResponse.metadata.exams
              .where((exam) => exam.status == 'In Progress')
              .toList();
          emit(HomepageLoaded(
            inProgressExam,
            hasReachedMax: true,
            currentPage: 1,
            isSearching: true,
            searchQuery: query,
          ));
        } catch (e) {
          _tokenCubit.handleTokenError(e);
          emit(HomepageError('Failed to search exams: $e'));
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
