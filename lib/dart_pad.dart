import 'package:exam_guardian/data/auth_repository.dart';
import 'package:exam_guardian/data/user_repository.dart';

void test() async {
  AuthRepository authRepository = AuthRepository();
  final adminResponse = await authRepository.login('admin', '123');
  final findUserById = await authRepository.getUserInfo();
  print('User info: ${findUserById.name}');

}

void main(){
}