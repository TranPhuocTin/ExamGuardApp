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
    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if(clientId == null || token == null) throw Exception('Token null in statistics');
      final response = await _repository.getCheatingStatistics(clientId, token, examId);
      emit(CheatingStatisticsLoaded(statistics: response.metadata.statistics));
    } catch (e) {
      emit(CheatingStatisticsError(e.toString()));
    }
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

  Future<void> handleNewCheatingDetected(Map<String, dynamic> message) async {
    print('🔄 handleNewCheatingDetected được gọi với message: $message');
    print('Current state: $state');

    try {
      // Thêm cơ chế retry nếu state chưa sẵn sàng
      int retryCount = 0;
      while (state is! CheatingStatisticsLoaded && retryCount < 3) {
        print('⏳ Đang đợi state sẵn sàng... Lần thử: ${retryCount + 1}');
        await Future.delayed(Duration(milliseconds: 500));
        retryCount++;
      }

      if (state is! CheatingStatisticsLoaded) {
        print('⚠️ State vẫn chưa sẵn sàng sau $retryCount lần thử');
        return;
      }

      // Xử lý data an toàn hơn
      final data = message['data'];
      if (data == null) {
        print('⚠️ Message data is null');
        return;
      }

      final cheatingData = data as Map<String, dynamic>;
      final currentState = state as CheatingStatisticsLoaded;
      final currentStats = List<CheatingStatistic>.from(currentState.statistics);

      // Kiểm tra và xử lý student data
      final studentData = cheatingData['student'];
      if (studentData == null || studentData is! Map<String, dynamic>) {
        print('⚠️ Student data không hợp lệ');
        return;
      }

      // Tạo student object với null safety
      final student = Student(
        id: studentData['_id']?.toString() ?? '',
        username: studentData['username']?.toString() ?? '',
        name: studentData['name']?.toString() ?? '',
        email: studentData['email']?.toString() ?? '',
        avatar: studentData['avatar']?.toString() ?? '',
      );

      print('🔍 Tìm kiếm student với ID: ${student.id}');
      
      final existingStatIndex = currentStats.indexWhere(
        (stat) => stat.student.id == student.id
      );
      
      if (existingStatIndex != -1) {
        // Update existing student statistics với null safety
        final existingStat = currentStats[existingStatIndex];
        final updatedStat = existingStat.copyWith(
          faceDetectionCount: cheatingData['faceDetectionCount'] as int? ?? 0,
          tabSwitchCount: cheatingData['tabSwitchCount'] as int? ?? 0,
          screenCaptureCount: cheatingData['screenCaptureCount'] as int? ?? 0,
        );
        currentStats[existingStatIndex] = updatedStat;
        print('✅ Đã cập nhật thống kê cho student ${student.name}');
      } else {
        // Create new statistics với null safety
        final examData = cheatingData['exam'] as Map<String, dynamic>?;
        if (examData == null) {
          print('⚠️ Exam data không hợp lệ');
          return;
        }

        final newStat = CheatingStatistic(
          id: cheatingData['_id']?.toString() ?? '',
          student: student,
          exam: Exam(
            id: examData['_id']?.toString() ?? '',
            title: examData['title']?.toString() ?? ''
          ),
          faceDetectionCount: cheatingData['faceDetectionCount'] as int? ?? 0,
          tabSwitchCount: cheatingData['tabSwitchCount'] as int? ?? 0,
          screenCaptureCount: cheatingData['screenCaptureCount'] as int? ?? 0,
          totalViolations: (cheatingData['faceDetectionCount'] as int? ?? 0) +
              (cheatingData['tabSwitchCount'] as int? ?? 0) +
              (cheatingData['screenCaptureCount'] as int? ?? 0),
          createdAt: DateTime.tryParse(cheatingData['createdAt']?.toString() ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(cheatingData['updatedAt']?.toString() ?? '') ?? DateTime.now(),
        );
        currentStats.add(newStat);
        print('✅ Đã thêm thống kê mới cho student ${student.name}');
      }

      emit(CheatingStatisticsLoaded(
        statistics: currentStats,
        hasReachedMax: currentState.hasReachedMax,
      ));
      print('✨ Đã emit state mới thành công');
    } catch (e) {
      print('❌ Lỗi khi xử lý message: $e');
    }
  }
}