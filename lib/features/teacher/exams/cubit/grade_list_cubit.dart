import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../model/grade_list_response.dart';
import 'grade_list_state.dart';

class GradeListCubit extends Cubit<GradeListState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;

  GradeListCubit({
    required ExamRepository examRepository,
    required TokenStorage tokenStorage,
    required TokenCubit tokenCubit,
  })  : _examRepository = examRepository,
        _tokenStorage = tokenStorage,
        _tokenCubit = tokenCubit,
        super(GradeListInitial());

  Future<void> loadGrades({
    required String examId,
    bool isLoadMore = false,
  }) async {
    try {
      print('Loading grades for exam: $examId, isLoadMore: $isLoadMore');
      final currentState = state;
      
      // If already loading or reached max for load more, return
      if (currentState is GradeListLoading) return;
      if (isLoadMore && currentState is GradeListLoaded && currentState.hasReachedMax) return;

      // Get current grades if loading more
      final List<GradeDetail> currentGrades = currentState is GradeListLoaded ? currentState.grades : [];
      
      // Emit loading state
      emit(GradeListLoading(currentGrades, isFirstFetch: !isLoadMore));

      // Get authentication info
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();

      if (clientId == null || token == null) {
        emit(GradeListError('Authentication information is missing'));
        return;
      }

      // Get current page
      final page = currentState is GradeListLoaded ? currentState.currentPage + 1 : 1;

      // Fetch grades
      final response = await _examRepository.getExamGrades(
        clientId,
        token,
        examId,
        page: page,
      );
      print('Received grades response: ${response.metadata.grades.length} items');

      // Get new grades
      final newGrades = response.metadata.grades;
      final hasReachedMax = newGrades.isEmpty;

      if (isLoadMore) {
        emit(GradeListLoaded(
          grades: [...currentGrades, ...newGrades],
          hasReachedMax: hasReachedMax,
          currentPage: page,
        ));
      } else {
        emit(GradeListLoaded(
          grades: newGrades,
          hasReachedMax: hasReachedMax,
          currentPage: page,
        ));
      }
    } catch (e) {
      print('Error loading grades: $e');
      _tokenCubit.handleTokenError(e);
      emit(GradeListError(e.toString()));
    }
  }
} 