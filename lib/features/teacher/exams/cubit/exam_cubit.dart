import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exam_guardian/data/exam_repository.dart';
import 'package:exam_guardian/features/teacher/models/exam.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';

import 'exam_state.dart';

// State

// Cubit
class ExamCubit extends Cubit<ExamState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;

  ExamCubit(this._examRepository, this._tokenStorage) : super(ExamInitial());

  Future<void> loadInProgressExams({bool forceReload = false}) async {
    final currentState = state;

    if (currentState is ExamLoading) return;

    List<Exam> oldExams = [];
    if (currentState is ExamLoaded) {
      oldExams = currentState.exams;
    }

    if (forceReload) {
      emit(ExamRefreshing(oldExams));
    } else {
      emit(ExamLoading(oldExams, isFirstFetch: currentState is ExamInitial));
    }

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      final status = 'In Progress';
      if (clientId == null || token == null) {
        emit(ExamError('Authentication information is missing'));
        return;
      }

      final examResponse = await _examRepository.getInProgressExams(clientId, token, status: status);
      
      emit(ExamLoaded(
        examResponse.metadata.exams,
        hasReachedMax: true, // Vì chúng ta tải tất cả dữ liệu, nên đặt hasReachedMax là true
      ));
    } on TokenExpiredException {
      emit(ExamError('Session expired. Please log in again.'));
    } catch (e) {
      emit(ExamError('Failed to load exams: $e'));
    }
  }

  void resetState() {
    emit(ExamInitial());
  }
}
