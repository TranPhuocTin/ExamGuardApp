import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import 'exam_submission_state.dart';

class ExamSubmissionCubit extends Cubit<ExamSubmissionState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;

  ExamSubmissionCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  })  : _examRepository = examRepository,
        _tokenStorage = tokenStorage,
        _tokenCubit = tokenCubit,
        super(ExamSubmissionInitial());

  Future<void> submitExam(String examId) async {
    try {
      emit(ExamSubmissionLoading());

      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      if (clientId != null && token != null) {
        await _examRepository.submitExam(clientId, token, examId);
        emit(ExamSubmissionSuccess());
      } else {
        throw Exception('Missing authentication credentials');
      }
    } catch (e) {
      _tokenCubit.handleTokenError(e);
      emit(ExamSubmissionFailure(e.toString()));
    }
  }
}