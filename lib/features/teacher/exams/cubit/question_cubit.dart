import 'package:exam_guardian/data/exam_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import '../../../common/models/question_response.dart';
import 'question_state.dart';

class QuestionCubit extends Cubit<QuestionState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  String? _currentExamId;

  QuestionCubit(this._examRepository, this._tokenStorage) : super(QuestionInitial());

  Future<void> loadQuestions({required String examId, bool forceReload = false}) async {
    if (state is QuestionLoading) return;

    final currentState = state;
    if (currentState is QuestionLoaded && !forceReload && examId == _currentExamId) {
      emit(QuestionLoading(currentState.questions, isFirstFetch: false));
    } else {
      emit(QuestionLoading([], isFirstFetch: true));
    }

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(QuestionError('Authentication information is missing'));
        return;
      }

      final response = await _examRepository.getQuestions(
        clientId,
        token,
        examId,
        page: 1,
      );

      _currentExamId = examId;
      emit(QuestionLoaded(
        response.metadata.questions,
        hasReachedMax: response.metadata.questions.length >= response.metadata.total,
        currentPage: 1,
        examId: examId,
      ));
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> loadMoreQuestions() async {
    final currentState = state;
    if (currentState is! QuestionLoaded || currentState.hasReachedMax) return;
    if (_currentExamId == null) return;

    emit(QuestionLoading(currentState.questions, isFirstFetch: false));

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(QuestionError('Authentication information is missing'));
        return;
      }

      final response = await _examRepository.getQuestions(
        clientId,
        token,
        _currentExamId!,
        page: currentState.currentPage + 1,
      );

      if (response.metadata.questions.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        emit(QuestionLoaded(
          [...currentState.questions, ...response.metadata.questions],
          hasReachedMax: (currentState.questions.length + response.metadata.questions.length) >= response.metadata.total,
          currentPage: currentState.currentPage + 1,
          examId: _currentExamId!,
        ));
      }
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> createQuestion(String examId, Question question) async {
    print('QuestionCubit: Starting to create question');
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        print('QuestionCubit: Authentication information is missing');
        emit(QuestionError('Authentication information is missing'));
        return;
      }
      print('QuestionCubit: Calling repository to create question');
      final createdQuestion = await _examRepository.createQuestion(clientId, token, examId, question);
      print('QuestionCubit: Question created successfully');
      emit(QuestionCreated(createdQuestion));
      print('QuestionCubit: Reloading questions');
      await loadQuestions(examId: examId);
    } catch (e) {
      print('QuestionCubit: Error creating question - ${e.toString()}');
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> updateQuestion(String examId, String questionId, Question question) async {
    try {
      print('On update question');
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(QuestionError('Authentication information is missing'));
        return;
      }
      final updatedQuestion = await _examRepository.updateQuestion(clientId, token, examId, questionId, question);
      emit(QuestionUpdated());
      await loadQuestions(examId: examId);
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  }

  Future<void> deleteQuestion(String examId, String questionId) async {
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(QuestionError('Authentication information is missing'));
        return;
      }
      await _examRepository.deleteQuestion(clientId, token, examId, questionId);
      // emit(QuestionDeleted(questionId));
      await loadQuestions(examId: examId);
    } catch (e) {
      emit(QuestionError(e.toString()));
    }
  } 
}
