import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:exam_guardian/data/user_repository.dart';
import 'package:exam_guardian/features/admin/cubit/user_cubit.dart';
import 'package:exam_guardian/features/admin/view/admin_profile_view.dart';
import 'package:exam_guardian/features/admin/view/admin_homepage_view.dart';
import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
import 'package:exam_guardian/features/login/view/login_view.dart';
import 'package:exam_guardian/features/teacher/exams/view/create_update_exam_view.dart';
import 'package:exam_guardian/features/teacher/homepage/view/teacher_homepage_view.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'package:exam_guardian/utils/share_preference/token_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ExamGuardObserver.dart';
import 'data/exam_repository.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/teacher/exams/cubit/exam_cubit.dart';
import 'features/teacher/exams/cubit/question_cubit.dart';
import 'features/teacher/homepage/cubit/teacher_homepage_cubit.dart';

void main() {
  UserRepository userRepository = UserRepository();
  ExamRepository examRepository = ExamRepository();
  TokenStorage tokenStorage = TokenStorage();

  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider<UserRepository>(
        create: (context) => userRepository,
      ),
      RepositoryProvider<ExamRepository>(
        create: (context) => examRepository,
      ),
      RepositoryProvider<TokenStorage>(
        create: (context) => tokenStorage,
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(userRepository),
        ),
        BlocProvider<TokenCubit>(
          create: (context) => TokenCubit(tokenStorage),
        ),
        BlocProvider<TeacherHomepageCubit>(
          create: (context) => TeacherHomepageCubit(examRepository, tokenStorage),
        ),
        BlocProvider<ExamCubit>(
          create: (context) => ExamCubit(examRepository, tokenStorage),
        ),
        BlocProvider<QuestionCubit>(
          create: (context) => QuestionCubit(examRepository, tokenStorage),
        ),
      ],
      child: MyApp(),
    ),
  ));
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
        '/teacher_homepage' : (context) => TeacherHomepageView(),
        '/teacher_homepage' : (context) => TeacherHomepageView(),
      },
    );
  }
}
