import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/cheating_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/mixins/pagination_mixin.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../model/cheating_history_response.dart';
import 'cheating_history_state.dart';

class CheatingHistoryCubit extends Cubit<CheatingHistoryState> with PaginationMixin<CheatingHistory> {
  final CheatingRepository _repository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  static const int _pageSize = 10;
  String? _currentExamId;
  String? _currentStudentId;
  String? _currentFilter;
  
  CheatingHistoryCubit(
    this._repository,
    this._tokenStorage,
      this._tokenCubit
  ) : super(CheatingHistoryInitial()) {
    initializePagination(initialPage: 1);
  }

  Future<void> loadHistories(
    String examId, 
    String studentId, {
    bool refresh = false,
    String? infractionType,
  }) async {
    if (refresh) {
      emit(CheatingHistoryLoading());
      resetPagination();
      _currentExamId = examId;
      _currentStudentId = studentId;
      _currentFilter = infractionType;
    } else if (isLoading || hasReachedMax) {
      return;
    }

    if (_currentExamId != examId || 
        _currentStudentId != studentId || 
        _currentFilter != infractionType) {
      resetPagination();
      _currentExamId = examId;
      _currentStudentId = studentId;
      _currentFilter = infractionType;
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
        infractionType: infractionType,
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
      _tokenCubit.handleTokenError(e);
      emit(CheatingHistoryError(e.toString()));
    } finally {
      setLoading(false);
    }
  }

  Future<void> refreshHistories(
    String examId, 
    String studentId, {
    String? infractionType,
  }) async {
    await loadHistories(
      examId, 
      studentId, 
      refresh: true,
      infractionType: infractionType,
    );
  }

  void filterHistories(String? infractionType) {
    if (_currentExamId != null && _currentStudentId != null) {
      loadHistories(
        _currentExamId!, 
        _currentStudentId!,
        refresh: true,
        infractionType: infractionType,
      );
    }
  }
}
