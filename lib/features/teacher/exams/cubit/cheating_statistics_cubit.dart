import 'package:exam_guardian/data/cheating_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../model/cheating_statistics_response.dart';
import 'cheating_statistics_state.dart';

class CheatingStatisticsCubit extends Cubit<CheatingStatisticsState> {
  final CheatingRepository _repository;
  final TokenStorage _tokenStorage;
  final TokenCubit _tokenCubit;
  int _currentPage = 1;
  static const int _pageSize = 10;
  
  CheatingStatisticsCubit(
    this._repository,
    this._tokenStorage,
      this._tokenCubit
  ) : super(CheatingStatisticsInitial());

  Future<void> loadStatistics(String examId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        emit(CheatingStatisticsLoading());
      }

      if (state is CheatingStatisticsLoading) return;

      final currentState = state;
      if (currentState is CheatingStatisticsLoaded && !refresh) {
        if (currentState.hasReachedMax) return;
      }

      final token = await _tokenStorage.getAccessToken();
      final clientId = await _tokenStorage.getClientId();

      if (token == null || clientId == null) {
        emit(const CheatingStatisticsError('Authentication information missing'));
        return;
      }

      final response = await _repository.getCheatingStatistics(
        clientId,
        token,
        examId,
        page: _currentPage,
        limit: _pageSize,
      );

      final statistics = response.metadata.statistics;
      final hasReachedMax = statistics.length < _pageSize;

      if (currentState is CheatingStatisticsLoaded && !refresh) {
        _currentPage++;
        emit(CheatingStatisticsLoaded(
          statistics: [...currentState.statistics, ...statistics],
          hasReachedMax: hasReachedMax,
        ));
      } else {
        _currentPage = 2;
        emit(CheatingStatisticsLoaded(
          statistics: statistics,
          hasReachedMax: hasReachedMax,
        ));
      }
    } catch (e) {
      _tokenCubit.handleTokenError(e);
      emit(CheatingStatisticsError(e.toString()));
    }
  }

  Future<void> refreshStatistics(String examId) async {
    await loadStatistics(examId, refresh: true);
  }

  void filterStatistics(String query) {
    final currentState = state;
    if (currentState is CheatingStatisticsLoaded) {
      final filteredStats = currentState.statistics.where((stat) {
        final studentName = stat.student.name.toLowerCase();
        final studentEmail = stat.student.email.toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return studentName.contains(searchQuery) || 
               studentEmail.contains(searchQuery);
      }).toList();

      emit(CheatingStatisticsLoaded(
        statistics: filteredStats,
        hasReachedMax: true,
      ));
    }
  }

  void handleNewCheatingDetected(Map<String, dynamic> cheatingData) {
    print('🔄 handleNewCheatingDetected được gọi với data: $cheatingData');
    
    if (state is CheatingStatisticsLoaded) {
      final currentState = state as CheatingStatisticsLoaded;
      final currentStats = List<CheatingStatistic>.from(currentState.statistics);
      
      final studentData = cheatingData['student'];
      if (studentData == null) {
        print('⚠️ Student data is null');
        return;
      }

      String studentId;
      if (studentData is String) {
        studentId = studentData;
      } else if (studentData is Map<String, dynamic>) {
        studentId = studentData['_id'] as String;
      } else {
        print('⚠️ Invalid student data format');
        return;
      }

      print('🔍 Tìm kiếm student với ID: $studentId');
      
      final existingStatIndex = currentStats.indexWhere(
        (stat) => stat.student?.id == studentId
      );
      print('📍 existingStatIndex: $existingStatIndex');

      if (existingStatIndex != -1) {
        print('✅ Tìm thấy student trong danh sách');
        final existingStat = currentStats[existingStatIndex];
        final newFaceCount = cheatingData['faceDetectionCount'] as int;
        final newTabCount = cheatingData['tabSwitchCount'] as int;
        final newScreenCount = cheatingData['screenCaptureCount'] as int;
        
        print('📊 Counts mới: face=$newFaceCount, tab=$newTabCount, screen=$newScreenCount');
        print('📊 Counts cũ: face=${existingStat.faceDetectionCount}, tab=${existingStat.tabSwitchCount}, screen=${existingStat.screenCaptureCount}');

        final updatedStat = existingStat.copyWith(
          faceDetectionCount: newFaceCount,
          tabSwitchCount: newTabCount,
          screenCaptureCount: newScreenCount,
        );

        currentStats[existingStatIndex] = updatedStat;
        print('🔄 Chuẩn bị emit state mới');
        emit(CheatingStatisticsLoaded(
          statistics: List<CheatingStatistic>.from(currentStats),
          hasReachedMax: currentState.hasReachedMax,
        ));
        print('✅ Đã emit state mới');
      } else {
        print('⚠️ Không tìm thấy student trong danh sách');
      }
    } else {
      print('⚠️ State hiện tại không phải là CheatingStatisticsLoaded');
    }
  }
}