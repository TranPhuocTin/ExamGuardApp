import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import 'answer_submission_state.dart';

class AnswerSubmissionCubit extends Cubit<AnswerSubmissionState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;

  AnswerSubmissionCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  })  : _examRepository = examRepository,
        _tokenStorage = tokenStorage,
        _tokenCubit = tokenCubit,
        super(AnswerSubmissionInitial());

  Future<void> submitAnswer(String questionId, String answer) async {
    try {
      print('🎯 AnswerSubmissionCubit - Submit answer details:');
      print('- Question ID: $questionId');
      print('- Answer: $answer');
      print('- Timestamp: ${DateTime.now()}');

      emit(AnswerSubmissionLoading(questionId: questionId));

      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      if (clientId != null && token != null) {
        print('📤 Sending answer to server...');
        await _examRepository.submitAnswer(
          questionId,
          answer,
          clientId,
          token,
        );
        print('✅ Answer submitted successfully!');
        print('- Question ID: $questionId');
        print('- Answer: $answer');
        print('- Time: ${DateTime.now()}');

        emit(AnswerSubmissionSuccess(
          questionId: questionId,
          answer: answer,
        ));
      } else {
        throw Exception('Missing authentication credentials');
      }
    } catch (e) {
      print('❌ Error submitting answer:');
      print('- Question ID: $questionId'); 
      print('- Attempted answer: $answer');
      print('- Error: $e');
      _tokenCubit.handleTokenError(e);
      emit(AnswerSubmissionFailure(
        questionId: questionId,
        error: e.toString(),
      ));
    }
  }
} 