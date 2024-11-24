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

      // Extract student information
      String studentId;
      Student? student;
      
      if (studentData is String) {
        studentId = studentData;
        // Tạo student cố định cho testing
        student = Student(
          id: studentId,
          username: 'test_student',
          name: 'Test Student',
          email: 'test@example.com',
          avatar: '',
        );
      } else if (studentData is Map<String, dynamic>) {
        studentId = studentData['_id'] as String;
        // Create Student object from the data
        student = Student(
          id: studentData['_id'] as String,
          username: studentData['username'] as String,
          name: studentData['name'] as String,
          email: studentData['email'] as String,
          avatar: studentData['avatar'] as String? ?? '',
        );
      } else {
        print('⚠️ Invalid student data format');
        return;
      }

      print('🔍 Tìm kiếm student với ID: $studentId');
      
      final existingStatIndex = currentStats.indexWhere(
        (stat) => stat.student?.id == studentId
      );
      
      if (existingStatIndex != -1) {
        // Update existing student statistics
        final existingStat = currentStats[existingStatIndex];
        final updatedStat = existingStat.copyWith(
          faceDetectionCount: cheatingData['faceDetectionCount'] as int,
          tabSwitchCount: cheatingData['tabSwitchCount'] as int,
          screenCaptureCount: cheatingData['screenCaptureCount'] as int,
        );
        currentStats[existingStatIndex] = updatedStat;
      } else {
        // Create new statistics for the student
        if (student != null) {
          final newStat = CheatingStatistic(
            id: cheatingData['_id'] as String,
            student: student,
            exam: Exam(id: cheatingData['exam'] as String, title: ''),
            faceDetectionCount: cheatingData['faceDetectionCount'] as int,
            tabSwitchCount: cheatingData['tabSwitchCount'] as int,
            screenCaptureCount: cheatingData['screenCaptureCount'] as int,
            totalViolations: (cheatingData['faceDetectionCount'] as int) +
                (cheatingData['tabSwitchCount'] as int) +
                (cheatingData['screenCaptureCount'] as int),
            createdAt: DateTime.parse(cheatingData['createdAt'] as String),
            updatedAt: DateTime.parse(cheatingData['updatedAt'] as String),
          );
          currentStats.add(newStat);
        }
      }

      emit(CheatingStatisticsLoaded(
        statistics: currentStats,
        hasReachedMax: currentState.hasReachedMax,
      ));
    }
  }
}