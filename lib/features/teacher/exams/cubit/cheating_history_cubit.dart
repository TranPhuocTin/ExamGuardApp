import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/cheating_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/mixins/pagination_mixin.dart';
import '../model/cheating_history_response.dart';
import 'cheating_history_state.dart';

class CheatingHistoryCubit extends Cubit<CheatingHistoryState> with PaginationMixin<CheatingHistory> {
  final CheatingRepository _repository;
  final TokenStorage _tokenStorage;
  static const int _pageSize = 10;
  String? _currentExamId;
  String? _currentStudentId;
  
  CheatingHistoryCubit(
    this._repository,
    this._tokenStorage,
  ) : super(CheatingHistoryInitial()) {
    initializePagination(initialPage: 1);
  }

  Future<void> loadHistories(String examId, String studentId, {bool refresh = false}) async {
    if (refresh) {
      emit(CheatingHistoryLoading());
      resetPagination();
      _currentExamId = examId;
      _currentStudentId = studentId;
    } else if (isLoading || hasReachedMax) {
      return;
    }

    if (_currentExamId != examId || _currentStudentId != studentId) {
      resetPagination();
      _currentExamId = examId;
      _currentStudentId = studentId;
    }

    setLoading(true);

    try {
      final token = await _tokenStorage.getAccessToken();
      final clientId = await _tokenStorage.getClientId();

      if (token == null || clientId == null) {
        emit(const CheatingHistoryError('Authentication information missing'));
        return;
      }

      final response = await _repository.getCheatingHistories(
        clientId,
        token,
        examId,
        studentId,
        page: currentPage,
        limit: _pageSize,
      );

      final histories = response.metadata.histories;
      final hasReached = histories.length < _pageSize;

      if (state is CheatingHistoryLoaded && !refresh) {
        final currentState = state as CheatingHistoryLoaded;
        final updatedHistories = [...currentState.histories, ...histories];
        
        updatePaginationState(
          newItems: updatedHistories,
          hasReachedMax: hasReached,
        );

        emit(CheatingHistoryLoaded(
          histories: updatedHistories,
          hasReachedMax: hasReached,
        ));
      } else {
        updatePaginationState(
          newItems: histories,
          hasReachedMax: hasReached,
        );

        emit(CheatingHistoryLoaded(
          histories: histories,
          hasReachedMax: hasReached,
        ));
      }
    } catch (e) {
      emit(CheatingHistoryError(e.toString()));
    } finally {
      setLoading(false);
    }
  }

  Future<void> refreshHistories(String examId, String studentId) async {
    await loadHistories(examId, studentId, refresh: true);
  }
}
