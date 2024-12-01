class ApiUrls {
  static String login = '/api/auth/login';
  static String getTeacherOrStudentList = '/api/user/list';
  static String findUserById(String userId) => '/v1/api/user/$userId';
  static String searchUser = '/api/user/search';
  static String deleteUser(String userId) => '/api/user/$userId';
  static String updateUser(String userId) => '/api/user/$userId';
  static String logout = '/api/auth/logout';
  static const String getExamList = '/api/exam/list';
  static const String getSearchExam = '/api/exam/search';
  static String updateExam(String examId) => '/api/exam/$examId';
  static String deleteExam(String examId) => '/api/exam/$examId';
  static String createExam = '/api/exam/create';
  static String getQuestionList(String examId) => '/api/question/$examId/list';
  static String createQuestion(String examId) => '/api/question/$examId/create';
  static String updateQuestion(String examId, String questionId) => '/api/question/$examId/$questionId';
  static String deleteQuestion(String examId, String questionId) => '/api/question/$examId/$questionId';
  static String reportCheating(String examId) => '/api/cheating/detect-cheating/$examId';
  static String getcheatingStatistics(String examId) => '/api/cheating/list-cheating-statistics/$examId';
  static String joinExam(String examId) => '/api/exam/join/$examId';
  static String getCheatingHistories(String examId, String studentId) => '/api/cheating/list-cheating-histories-by-student/$examId/$studentId';
  static String submitExam(String examId) => '/api/exam/submit/$examId';
  static String getGrade(String examId) => '/api/grade/view-grade/$examId';
  static String getExamGrades(String examId) => '/api/grade/list-by-exam/$examId';
  static String getStudentAnswer(String examId, String studentId) => '/api/answer/$examId/list-by-student/$studentId';
}
