  import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/data/base_repository.dart';
import 'package:exam_guardian/features/common/models/exam_response.dart';
import '../configs/dio_client.dart';
import '../features/common/models/exam.dart';
import '../features/common/models/question_response.dart';
import '../features/student/exam/models/student_exam_response.dart';
import '../utils/exceptions/token_exceptions.dart';

class ExamRepository /*extends BaseRepository*/{
  Future<ExamResponse> getExams(String clientId, String token, {String? status, int page = 1}) async {
    final response = await DioClient.performRequest(
      ApiUrls.getExamList,
      clientId: clientId,
      token: token,
      queryParameters: {'status': status, 'page': page},
    );
    return ExamResponse.fromJson(response.data);
  }

  //20/11 handle for searchExams
  Future<ExamResponse> searchExams(String clientId, String token, String query, {int page = 1}) async {
    final response = await DioClient.performRequest(
        ApiUrls.getSearchExam,
        clientId: clientId,
        token: token,
        queryParameters: {'query': query, 'page': page}
    );
    return ExamResponse.fromJson(response.data);
  }

  Future<Exam> updateExam(String clientId, String token, String examId, Exam exam) async {
    final response = await DioClient.performRequest(
      ApiUrls.updateExam(examId),
      clientId: clientId,
      token: token,
      data: exam.toJson(),
      method: 'PATCH',
    );
    return Exam.fromJson(response.data['metadata']);
  }

  Future<void> deleteExam(String clientId, String token, String examId) async {
    await DioClient.performRequest(
      ApiUrls.deleteExam(examId),
      clientId: clientId,
      token: token,
      method: 'DELETE'
    );
  }

  Future<Exam> createExam(String clientId, String token, Exam exam) async {
    final response = await DioClient.performRequest(
      ApiUrls.createExam,
      clientId: clientId,
      token: token,
      data: exam.toJson(),
      method: 'POST'
    );
    return Exam.fromJson(response.data['metadata']);
  }

  Future<QuestionResponse> getQuestions(String clientId, String token, String examId, {int page = 1}) async {
    final response = await DioClient.performRequest(
      ApiUrls.getQuestionList(examId),
      clientId: clientId,
      token: token,
      queryParameters: {'page': page}
    );
    return QuestionResponse.fromJson(response.data);
  }

  Future<Question> createQuestion(String clientId, String token, String examId, Question question) async {
    print('ExamRepository: Starting to create question');
    print('ExamRepository: ExamId - $examId');
    print('ExamRepository: Question details - ${question.toJson()}');
    try {
      final response = await DioClient.performRequest(
        ApiUrls.createQuestion(examId),
        clientId: clientId,
        token: token,
        data: question.toJson(),
        method: 'POST',
      );
      print('ExamRepository: Question created successfully');
      print('ExamRepository: Response data - ${response.data}');
      return Question.fromJson(response.data['metadata']);
    } catch (e) {
      print('ExamRepository: Error creating question - ${e.toString()}');
      rethrow;
    }
  }

  Future<Question> updateQuestion(String clientId, String token, String examId, String questionId, Question question) async {
    final response = await DioClient.performRequest(
      ApiUrls.updateQuestion(examId, questionId),
      clientId: clientId,
      token: token,
      data: question.toJson(),
      method: 'PATCH'
    );
    return Question.fromJson(response.data['metadata']);
  }

  Future<void> deleteQuestion(String clientId, String token, String examId, String questionId) async {
    await DioClient.performRequest(
      ApiUrls.deleteQuestion(examId, questionId),
      clientId: clientId,
      token: token,
      method: 'DELETE'
    );
  }

  Future<StudentExamResponse> joinExam(String clientId, String token, String examId, int page) async {
    try {
      final response = await DioClient.performRequest(
        ApiUrls.joinExam(examId),
        clientId: clientId,
        queryParameters: {
          'page': page,
          'limit': 10,
        },
        token: token,
        method: 'GET',
      );
      
      print('Response data: ${response.data}');
      
      return StudentExamResponse.fromJson(response.data);
    } catch (e) {
      print('ExamRepository: Lỗi khi join exam - ${e.toString()}');
      rethrow;
    }
  }

  Future<void> submitAnswer(String questionId, String answerText, String clientId, String token) async {
    try {
      await DioClient.performRequest(
        'https://exam-guard-server.onrender.com/api/answer/$questionId',
        clientId: clientId,
        token: token,
        method: 'POST',
        data: {
          'answerText': answerText,
        },
      );
    } catch (e) {
      print('ExamRepository: Lỗi khi submit answer - ${e.toString()}');
      rethrow;
    }
  }

  Future<void> submitExam(String clientId, String token, String examId) async {
    await DioClient.performRequest(
      ApiUrls.submitExam(examId),
      clientId: clientId,
      token: token,
      method: 'POST',
    );
  }
}
