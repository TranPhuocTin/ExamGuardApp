import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import 'grade_state.dart';

class GradeCubit extends Cubit<GradeState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;

  GradeCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  })  : _examRepository = examRepository,
        _tokenStorage = tokenStorage,
        _tokenCubit = tokenCubit,
        super(GradeInitial());

  Future<void> getGrade(String examId) async {
    try {
      emit(GradeLoading());

      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      if (clientId != null && token != null) {
        final response = await _examRepository.getGrade(clientId, token, examId);
        
        emit(GradeLoaded(
          score: response.metadata.score,
          createdAt: response.metadata.createdAt,
          updatedAt: response.metadata.updatedAt,
        ));
      } else {
        throw Exception('Missing authentication credentials');
      }
    } catch (e) {
      _tokenCubit.handleTokenError(e);
      emit(GradeError(e.toString()));
    }
  }
} 