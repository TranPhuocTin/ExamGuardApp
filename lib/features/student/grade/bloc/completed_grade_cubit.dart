import 'package:bloc/bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../models/completed_grade_response.dart';
import 'completed_grade_state.dart';

class CompletedGradeCubit extends Cubit<CompletedGradeState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  
  CompletedGradeCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  }) : _examRepository = examRepository,
       _tokenStorage = tokenStorage,
       _tokenCubit = tokenCubit,
       super(const CompletedGradeState());

  Future<void> fetchCompletedGrades() async {
    if (state.status == CompletedGradeStatus.loading) return;
    
    emit(state.copyWith(status: CompletedGradeStatus.loading));
    
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      if (clientId == null || token == null) {
        emit(state.copyWith(
          status: CompletedGradeStatus.failure,
          errorMessage: 'Authentication information is missing',
        ));
        return;
      }

      final response = await _examRepository.viewCompletedGrades(
        clientId,
        token,
        page: 1,
      );
      
      emit(state.copyWith(
        status: CompletedGradeStatus.success,
        grades: response.metadata.grades,
        currentPage: 1,
        totalPages: response.metadata.totalPages,
        hasReachedMax: response.metadata.grades.length >= response.metadata.total,
      ));
    } catch (error) {
      _tokenCubit.handleTokenError(error);
      emit(state.copyWith(
        status: CompletedGradeStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> fetchMoreCompletedGrades() async {
    if (state.hasReachedMax || state.status == CompletedGradeStatus.loading) return;
    
    emit(state.copyWith(status: CompletedGradeStatus.loading));
    
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      if (clientId == null || token == null) {
        emit(state.copyWith(
          status: CompletedGradeStatus.failure,
          errorMessage: 'Authentication information is missing',
        ));
        return;
      }

      final nextPage = state.currentPage + 1;
      final response = await _examRepository.viewCompletedGrades(
        clientId,
        token,
        page: nextPage,
      );
      
      emit(state.copyWith(
        status: CompletedGradeStatus.success,
        grades: [...state.grades, ...response.metadata.grades],
        currentPage: nextPage,
        hasReachedMax: (state.grades.length + response.metadata.grades.length) >= response.metadata.total,
      ));
    } catch (error) {
      _tokenCubit.handleTokenError(error);
      emit(state.copyWith(
        status: CompletedGradeStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void reset() {
    emit(const CompletedGradeState());
  }
} 