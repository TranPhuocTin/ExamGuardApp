import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/data/exam_repository.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import '../../../../utils/exceptions/token_exceptions.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../../../common/models/exam.dart';
import 'exam_state.dart';
import 'dart:async';

class ExamCubit extends Cubit<ExamState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  String _currentSearchQuery = '';
  Timer? _debounce;

  ExamCubit(this._examRepository, this._tokenStorage, this._tokenCubit) : super(ExamInitial());

  Future<void> loadExams({bool forceReload = false, String? status}) async {
    if (state is ExamLoading) return;

    final currentState = state;
    if (currentState is ExamLoaded) {
      emit(ExamLoading(currentState.exams, isFirstFetch: false));
    } else {
      emit(ExamLoading([], isFirstFetch: true));
    }

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(ExamError('Authentication information is missing'));
        return;
      }

      final examResponse = await _examRepository.getExams(
        clientId, 
        token, 
        status: status,
      );

      List<Exam> exams = examResponse.metadata.exams;
      
      if (status != null && status != 'All') {
        exams = exams.where((exam) => exam.status == status).toList();
      }

      emit(ExamLoaded(
        exams,
        hasReachedMax: examResponse.metadata.totalPages <= 1,
        currentPage: 1,
        selectedStatus: status ?? 'All',
      ));
    } catch (e) {
      if(e is TokenExpiredException){
        _tokenCubit.handleTokenError(e);
      }else{
        emit(ExamError(e.toString()));
      }
    }
  }

  Future<void> searchExams(String query) async {
    _currentSearchQuery = query;
    if (state is! ExamSearchState) {
      emit(ExamSearchState(searchQuery: query, isLoading: true));
    } else {
      emit((state as ExamSearchState).copyWith(searchQuery: query, isLoading: true, currentPage: 1, searchResults: []));
    }

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(ExamSearchState(error: 'Authentication information is missing'));
        return;
      }

      final examResponse = await _examRepository.searchExams(clientId, token, query);
      
      emit(ExamSearchState(
        searchResults: examResponse.metadata.exams,
        hasReachedMax: examResponse.metadata.exams.isEmpty,
        currentPage: 1,
        searchQuery: query,
        isLoading: false,
      ));
      // await loadExams();
    } catch (e) {
      if (e is TokenExpiredException) {
        _tokenCubit.handleTokenError(e);
      }
      emit(ExamSearchState(error: e.toString()));
    }
  }

  Future<void> refreshSearchResults() async {
    if (_currentSearchQuery.isNotEmpty) {
      await searchExams(_currentSearchQuery);
    }
  }

  void changeStatus(String status) {
    final currentState = state;
    if (currentState is ExamLoaded) {
      emit(currentState.copyWith(selectedStatus: status, currentPage: 1));
      loadExams(forceReload: true);
    }
  }

  void resetFilters() {
    final currentState = state;
    if (currentState is ExamLoaded) {
      emit(currentState.copyWith(selectedStatus: 'All', searchQuery: '', currentPage: 1));
      loadExams(forceReload: true);
    }
  }

  Future<void> loadMoreExams() async {
    if (state is ExamLoading) return;
    final currentState = state;
    if (currentState is ExamLoaded) {
      if (currentState.hasReachedMax) return;
      emit(ExamLoading(currentState.exams, isFirstFetch: false));
      try {
        final clientId = await _tokenStorage.getClientId();
        final token = await _tokenStorage.getAccessToken();
        if (clientId == null || token == null) {
          emit(ExamError('Authentication information is missing'));
          return;
        }
        final examResponse = await _examRepository.getExams(
          clientId,
          token,
          status: currentState.selectedStatus == 'All' ? null : currentState.selectedStatus,
          page: currentState.currentPage + 1,
        );
        final newExams = [...currentState.exams, ...examResponse.metadata.exams];
        emit(ExamLoaded(
          newExams,
          hasReachedMax: examResponse.metadata.exams.isEmpty,
          currentPage: currentState.currentPage + 1,
          selectedStatus: currentState.selectedStatus,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(ExamError(e.toString()));
      }
    }
  }

  Future<void> updateExam(Exam updatedExam, String outStatus) async {
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(ExamError('Authentication information is missing'));
        return;
      }

      await _examRepository.updateExam(
        clientId,
        token,
        updatedExam.id!,
        updatedExam,
      );

      emit(ExamUpdate(true)); // Emit a new state indicating successful update
      await loadExams(status: outStatus); // Reload exams with the same status
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  Future<void> deleteExam(String examId, String examStatus) async {
    try {
      final currentState = state as ExamLoaded;
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(ExamError('Authentication information is missing'));
        return;
      }
      await _examRepository.deleteExam(clientId, token, examId);
      await loadExams(status: examStatus);
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  Future<void> createExam(Exam exam) async {
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(ExamError('Authentication information is missing'));
        return;
      }

      await _examRepository.createExam(clientId, token, exam);
      emit(ExamUpdate(true)); // Emit success state
      await loadExams(status: exam.status); // Reload exams list
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  Future<void> loadMoreSearchResults() async {
    if (state is! ExamSearchState) return;
    final currentState = state as ExamSearchState;
    
    if (currentState.isLoading || currentState.hasReachedMax) return;

    emit(currentState.copyWith(isLoading: true));

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(currentState.copyWith(error: 'Authentication information is missing', isLoading: false));
        return;
      }

      final examResponse = await _examRepository.searchExams(
        clientId,
        token,
        currentState.searchQuery,
        page: currentState.currentPage + 1,
      );

      emit(currentState.copyWith(
        searchResults: [...currentState.searchResults, ...examResponse.metadata.exams],
        hasReachedMax: examResponse.metadata.exams.isEmpty,
        currentPage: currentState.currentPage + 1,
        isLoading: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void handleExamUpdated(Exam updatedExam) {
    if (state is ExamLoaded) {
      final currentState = state as ExamLoaded;
      final updatedExams = currentState.exams.map((exam) {
        return exam.id == updatedExam.id ? updatedExam : exam;
      }).toList();
      
      emit(ExamLoaded(
        updatedExams,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
        selectedStatus: currentState.selectedStatus,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
