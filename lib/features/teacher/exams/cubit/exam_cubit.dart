import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/data/exam_repository.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import '../../models/exam.dart';
import 'exam_state.dart';
import 'dart:async';

class ExamCubit extends Cubit<ExamState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  Timer? _debounce;

  ExamCubit(this._examRepository, this._tokenStorage) : super(ExamInitial());

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
      emit(ExamError(e.toString()));
    }
  }

  void searchExams(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final currentState = state;
      if (currentState is ExamLoaded) {
        emit(currentState.copyWith(searchQuery: query, currentPage: 1));
        loadExams(forceReload: true);
      }
    });
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

      final updatedExamFromApi = await _examRepository.updateExam(
        clientId,
        token,
        updatedExam.id,
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

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
