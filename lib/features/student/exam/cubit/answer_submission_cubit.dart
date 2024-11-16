import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import 'answer_submission_state.dart';

class AnswerSubmissionCubit extends Cubit<AnswerSubmissionState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;

  AnswerSubmissionCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
  })  : _examRepository = examRepository,
        _tokenStorage = tokenStorage,
        super(AnswerSubmissionInitial());

  Future<void> submitAnswer(String questionId, String answer) async {
    try {
      print('🎯 AnswerSubmissionCubit - Bắt đầu submit answer:');
      print('- Question ID: $questionId');
      print('- Answer: $answer');

      emit(AnswerSubmissionLoading(questionId: questionId));

      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      print('🔑 Token info:');
      print('- Client ID: $clientId');
      print('- Token available: ${token != null}');

      if (clientId != null && token != null) {
        print('📤 Đang gửi request đến server...');
        await _examRepository.submitAnswer(
          questionId,
          answer,
          clientId,
          token,
        );
        print('✅ Submit answer thành công!');

        emit(AnswerSubmissionSuccess(
          questionId: questionId,
          answer: answer,
        ));
      } else {
        throw Exception('Missing authentication credentials');
      }
    } catch (e) {
      print('❌ Lỗi khi submit answer:');
      print('- Error: $e');
      emit(AnswerSubmissionFailure(
        questionId: questionId,
        error: e.toString(),
      ));
    }
  }
} 