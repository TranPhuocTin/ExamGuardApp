import 'package:exam_guardian/data/user_repository.dart';
import 'package:exam_guardian/features/admin/cubit/user_cubit.dart';
import 'package:exam_guardian/features/admin/view/admin_profile_view.dart';
import 'package:exam_guardian/features/admin/view/admin_homepage_view.dart';
import 'package:exam_guardian/features/common/cubit/base_homepage_cubit.dart';
import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
import 'package:exam_guardian/features/login/view/login_view.dart';
import 'package:exam_guardian/features/realtime/cubit/realtime_cubit.dart';
import 'package:exam_guardian/features/teacher/exams/view/create_update_exam_view.dart';
import 'package:exam_guardian/features/teacher/homepage/view/teacher_homepage_view.dart';
import 'package:exam_guardian/services/socket_service.dart';
import 'package:exam_guardian/utils/navigation_service.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'package:exam_guardian/utils/share_preference/token_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ExamGuardObserver.dart';
import 'data/cheating_repository.dart';
import 'data/exam_repository.dart';
import 'features/notification/cubit/notification_cubit.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/student/exam/cubit/student_exam_cubit.dart';
import 'features/student/exam_monitoring/cubit/face_monitoring_cubit.dart';
import 'features/student/homepage/view/student_homepage_view.dart';
import 'features/teacher/exams/cubit/exam_cubit.dart';
import 'features/teacher/exams/cubit/question_cubit.dart';
import 'utils/widgets/global_error_handler.dart';
import 'services/notification_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TokenCubit(TokenStorage()),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(context.read<UserRepository>()),
        ),
        BlocProvider<ExamCubit>(
          create: (context) => ExamCubit(context.read<ExamRepository>(), context.read<TokenStorage>(), context.read<TokenCubit>()),
        ),
        BlocProvider<QuestionCubit>(
          create: (context) => QuestionCubit(context.read<ExamRepository>(), context.read<TokenStorage>(), context.read<TokenCubit>()),
        ),
        BlocProvider<BaseHomepageCubit>(
          create: (context) => BaseHomepageCubit(context.read<ExamRepository>(), context.read<TokenStorage>(), context.read<TokenCubit>()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: GlobalErrorHandler(
          child: SplashScreen(),
        ),
        routes: {
          '/login': (context) => LoginView(),
          '/admin_main_screen': (context) => AdminMainScreen(),
          '/admin_profile_screen': (context) => AdminProfileScreen(),
          '/teacher_homepage': (context) => TeacherHomepageView(),
          '/student_homepage': (context) => StudentHomepageView(),
        },
        navigatorKey: navigatorKey,
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  final tokenStorage = TokenStorage();
  final socketService = SocketService();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider<ExamRepository>(
          create: (context) => ExamRepository(),
        ),
        RepositoryProvider<TokenStorage>(
          create: (context) => tokenStorage,
        ),
        RepositoryProvider<CheatingRepository>(
          create: (context) => CheatingRepository(),
        ),
        RepositoryProvider<SocketService>(
          create: (context) => socketService,
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => notificationService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TokenCubit>(
            create: (context) => TokenCubit(tokenStorage),
          ),
          BlocProvider<NotificationCubit>(
            lazy: false,
            create: (context) => NotificationCubit(
              context.read<NotificationService>(),
              context,
            ),
          ),
          BlocProvider<RealtimeCubit>(
            create: (context) => RealtimeCubit(
              tokenStorage,
              socketService,
              notificationService,
            )..initializeSocket(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}