import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../common/models/question_response.dart';
import '../models/student_exam_response.dart';
import 'student_exam_state.dart';
import 'dart:async';
import '../../../../utils/mixins/pagination_mixin.dart';
import '../../../../utils/exceptions/exam_exceptions.dart';

class StudentExamCubit extends Cubit<StudentExamState> with PaginationMixin<Question> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final String examId;
  Timer? _timer;

  StudentExamCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
    required this.examId,
  })  : _examRepository = examRepository,
        _tokenStorage = tokenStorage,
        super(StudentExamInitial()) {
    initializePagination(initialPage: 1);
  }

  Future<void> loadExam({bool isLoadMore = false}) async {
    if (isLoading || (hasReachedMax && isLoadMore)) return;

    if (!isLoadMore) {
      emit(StudentExamLoading());
      resetPagination();
      _timer?.cancel();
    }

    setLoading(true);

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      
      if (clientId == null || token == null) {
        emit(const StudentExamError('Authentication information is missing'));
        return;
      }

      final response = await _examRepository.joinExam(
        clientId,
        token,
        examId,
        currentPage,
      );
      
      final questions = response.metadata.questions;
      final remainingTime = response.metadata.remainingTime;
      final total = response.metadata.total;
      
      final newQuestions = isLoadMore 
          ? [...items, ...questions]
          : questions;

      final hasReached = currentPage * questions.length >= total!;

      updatePaginationState(
        newItems: newQuestions,
        hasReachedMax: hasReached,
      );

      emit(StudentExamLoaded(
        questions: newQuestions,
        remainingTime: remainingTime,
        hasReachedMax: hasReached,
        isLoading: false,
      ));

      if (!isLoadMore) {
        _startTimer(remainingTime);
      }
    } on ExamAlreadyTakenException {
      emit(const StudentExamError('You have already completed this exam'));
      // setLoading(false);
      throw ExamAlreadyTakenException();
    } catch (e) {
      emit(StudentExamError(e.toString()));
      setLoading(false);
    }
  }

  Future<void> loadMoreQuestions() async {
    await loadExam(isLoadMore: true);
  }

  void selectAnswer(String questionId, String answer) {
    if (state is StudentExamLoaded) {
      final currentState = state as StudentExamLoaded;
      final newAnswers = Map<String, String>.from(currentState.answers);
      newAnswers[questionId] = answer;
      
      emit(currentState.copyWith(answers: newAnswers));
    }
  }

  void _startTimer(RemainingTime initialTime) {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is StudentExamLoaded) {
        final currentState = state as StudentExamLoaded;
        final currentMinutes = currentState.remainingTime.minutes;
        final currentSeconds = currentState.remainingTime.seconds;

        if (currentMinutes == 0 && currentSeconds == 0) {
          _timer?.cancel();
          // TODO: Implement auto-submit when time runs out
          return;
        }

        final newSeconds = currentSeconds > 0 ? currentSeconds - 1 : 59;
        final newMinutes = currentSeconds > 0 ? currentMinutes : currentMinutes - 1;

        emit(currentState.copyWith(
          remainingTime: RemainingTime(
            minutes: newMinutes,
            seconds: newSeconds,
          ),
        ));
      }
    });
  }

  Future<void> submitAnswer(String questionId, String answer) async {
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      
      if (clientId != null && token != null) {
        await _examRepository.submitAnswer(questionId, answer, clientId, token);
      }
    } catch (e) {
      print('Error submitting answer: $e');
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
} 