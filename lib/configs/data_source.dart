class ApiUrls {
  static String login = '/auth/login';
  static String getTeacherOrStudentList = '/v1/api/users';
  static String findUserById(String userId) => '/v1/api/user/${userId}';
  static String searchUser = '/v1/api/users/search';
  static String deleteUser(String userId) => '/v1/api/user/${userId}';
  static String logout = '/auth/logout';
}