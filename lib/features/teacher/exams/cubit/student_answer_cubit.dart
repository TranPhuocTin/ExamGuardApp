import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import 'student_answer_state.dart';
import '../model/student_answer_response.dart';
class StudentAnswerCubit extends Cubit<StudentAnswerState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  static const int _pageSize = 10;

  StudentAnswerCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  })  : _examRepository = examRepository,
        _tokenStorage = tokenStorage,
        _tokenCubit = tokenCubit,
        super(StudentAnswerInitial());

  Future<void> loadStudentAnswers(String examId, String studentId,
      {bool refresh = false}) async {
    try {
      if (state is StudentAnswerLoading) return;

      final currentState = state;
      List<StudentAnswer> oldAnswers = [];
      int currentPage = 1;

      if (currentState is StudentAnswerLoaded && !refresh) {
        if (currentState.hasReachedMax) return;
        oldAnswers = currentState.answers;
        currentPage = currentState.currentPage + 1;
      }

      emit(StudentAnswerLoading(oldAnswers, isFirstFetch: currentPage == 1));

      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      if (clientId == null || token == null) {
        throw Exception('Missing authentication credentials');
      }

      final response = await _examRepository.getStudentAnswer(
        clientId,
        token,
        examId,
        studentId,
      );

      final answers = response.metadata.answers;
      final hasReachedMax = answers.length < _pageSize;

      if (currentPage == 1) {
        emit(StudentAnswerLoaded(
          answers: answers,
          hasReachedMax: hasReachedMax,
          student: response.metadata.student,
          total: response.metadata.total,
          currentPage: currentPage,
        ));
      } else {
        emit(StudentAnswerLoaded(
          answers: oldAnswers + answers,
          hasReachedMax: hasReachedMax,
          student: response.metadata.student,
          total: response.metadata.total,
          currentPage: currentPage,
        ));
      }
    } catch (e) {
      _tokenCubit.handleTokenError(e);
      emit(StudentAnswerError(e.toString()));
    }
  }

  void resetState() {
    emit(StudentAnswerInitial());
  }
}
