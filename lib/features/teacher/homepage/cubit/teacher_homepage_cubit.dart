import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/data/exam_repository.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import '../../models/exam.dart';
import 'teacher_homepage_state.dart';

class TeacherHomepageCubit extends Cubit<TeacherHomepageState> {
  final ExamRepository _examRepository;
  final TokenStorage _tokenStorage;

  TeacherHomepageCubit(this._examRepository, this._tokenStorage) : super(TeacherHomepageInitial());

  Future<void> loadInProgressExams({bool forceReload = false}) async {
    if (state is TeacherHomepageLoading) return;

    final currentState = state;
    List<Exam> oldExams = [];
    int currentPage = 1;

    if (currentState is TeacherHomepageLoaded) {
      if (forceReload) {
        currentPage = 1;
        print('Force reloading, resetting to page 1');
      } else {
        oldExams = currentState.exams;
        currentPage = currentState.currentPage;
        print('Loading more exams, current page: $currentPage');
      }
    }

    if (currentState is TeacherHomepageInitial || forceReload) {
      emit(TeacherHomepageLoading(oldExams, isFirstFetch: currentState is TeacherHomepageInitial));
      print('Emitting TeacherHomepageLoading state (first fetch or force reload)');
    } else if (currentState is TeacherHomepageLoaded && !forceReload) {
      emit(TeacherHomepageLoading(oldExams, isFirstFetch: false));
      print('Emitting TeacherHomepageLoading state (loading more)');
    }

    try {
      final clientId = await _tokenStorage.getClientId();
      final token = await _tokenStorage.getAccessToken();
      if (clientId == null || token == null) {
        emit(TeacherHomepageError('Authentication information is missing'));
        print('Error: Authentication information is missing');
        return;
      }
      final String status = 'In Progress';
      print('Fetching exams for page: $currentPage');
      final examResponse = await _examRepository.getInProgressExams(clientId, token, page: currentPage, status: status);
      
      final newExams = forceReload ? examResponse.metadata.exams : [...oldExams, ...examResponse.metadata.exams];
      final hasReachedMax = examResponse.metadata.exams.isEmpty;

      print('Fetched ${examResponse.metadata.exams.length} exams');
      print('Total exams after fetch: ${newExams.length}');
      print('Has reached max: $hasReachedMax');

      emit(TeacherHomepageLoaded(
        newExams,
        hasReachedMax: hasReachedMax,
        currentPage: currentPage + 1,
      ));
      print('Emitted TeacherHomepageLoaded state, next page will be: ${currentPage + 1}');
    } on TokenExpiredException {
      emit(TeacherHomepageError('Session expired. Please log in again.'));
      print('Error: Token expired');
    } catch (e) {
      emit(TeacherHomepageError('Failed to load exams: $e'));
      print('Error loading exams: $e');
    }
  }

  void resetState() {
    emit(TeacherHomepageInitial());
    print('Reset state to TeacherHomepageInitial');
  }
}
