import 'package:exam_guardian/data/user_repository.dart';
import 'package:exam_guardian/features/admin/cubit/user_cubit.dart';
import 'package:exam_guardian/features/admin/view/admin_profile_view.dart';
import 'package:exam_guardian/features/admin/view/admin_homepage_view.dart';
import 'package:exam_guardian/features/login/cubit/AuthCubit.dart';
import 'package:exam_guardian/features/login/view/login_view.dart';
import 'package:exam_guardian/share_preference/shared_preference.dart';
import 'package:exam_guardian/share_preference/token_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ExamGuardObserver.dart';

import 'features/splash/screens/splash_screen.dart';

void main() {
  UserRepository userRepository = UserRepository();
  Bloc.observer = const Examguardobserver();
  TokenStorage tokenStorage = TokenStorage();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
    ),
    BlocProvider<UserCubit>(
      create: (context) => UserCubit(userRepository),
    ),
    BlocProvider<TokenCubit>(create: (context) => TokenCubit(tokenStorage),)
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => SplashScreen(), // SplashScreen làm màn hình mặc định
        '/login': (context) => LoginView(), // Màn hình chính
        '/admin_main_screen': (context) => AdminMainScreen(),
        '/admin_profile_screen': (context) => AdminProfileScreen(),
      },
    );
  }
}
