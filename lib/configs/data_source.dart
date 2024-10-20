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
}
