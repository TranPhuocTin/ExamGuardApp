import 'package:exam_guardian/data/auth_repository.dart';
import 'package:exam_guardian/data/user_repository.dart';
import 'package:exam_guardian/features/admin/cubit/user_cubit.dart';
import 'package:exam_guardian/features/admin/view/admin_profile_view.dart';
import 'package:exam_guardian/features/admin/view/admin_homepage_view.dart';
import 'package:exam_guardian/features/common/cubit/base_homepage_cubit.dart';
import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
import 'package:exam_guardian/features/login/view/login_view.dart';
import 'package:exam_guardian/features/realtime/cubit/realtime_cubit.dart';
import 'package:exam_guardian/features/teacher/exams/view/create_update_exam_view.dart';
import 'package:exam_guardian/features/teacher/exams/view/pip_test_view.dart';
import 'package:exam_guardian/features/teacher/homepage/view/teacher_homepage_view.dart';
import 'package:exam_guardian/screen_info_app.dart';
import 'package:exam_guardian/services/app_lifecycle_service.dart';
import 'package:exam_guardian/services/socket_service.dart';
import 'package:exam_guardian/utils/navigation_service.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'package:exam_guardian/utils/share_preference/token_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ExamGuardObserver.dart';
import 'data/cheating_repository.dart';
import 'data/exam_repository.dart';
import 'features/login/bloc/reset_password_cubit.dart';
import 'features/login/view/forgot_password_view.dart';
import 'features/login/view/verify_code_view.dart';
import 'features/notification/cubit/notification_cubit.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/student/exam/cubit/exam_submission_cubit.dart';
import 'features/student/exam/cubit/grade_cubit.dart';
import 'features/student/exam/cubit/student_exam_cubit.dart';
import 'features/student/exam_monitoring/cubit/app_monitoring_cubit.dart';
import 'features/student/exam_monitoring/cubit/face_monitoring_cubit.dart';
import 'features/student/homepage/view/student_homepage_view.dart';
import 'features/teacher/exams/cubit/exam_cubit.dart';
import 'features/teacher/exams/cubit/grade_list_cubit.dart';
import 'features/teacher/exams/cubit/question_cubit.dart';
import 'utils/widgets/global_error_handler.dart';
import 'services/notification_service.dart';
import 'data/noti_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        BlocProvider<ResetPasswordCubit>(
          create: (context) => ResetPasswordCubit(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        BlocProvider<ExamSubmissionCubit>(
          create: (context) => ExamSubmissionCubit(
            examRepository: context.read<ExamRepository>(),
            tokenStorage: context.read<TokenStorage>(),
            tokenCubit: context.read<TokenCubit>(),
          ),
        ),
        BlocProvider< GradeCubit>(
          create: (context) => GradeCubit(
            examRepository: context.read<ExamRepository>(),
            tokenStorage: context.read<TokenStorage>(),
            tokenCubit: context.read<TokenCubit>(),
          ),
        ),
        BlocProvider<GradeListCubit>(
          create: (context) => GradeListCubit(
            examRepository: context.read<ExamRepository>(),
            tokenStorage: context.read<TokenStorage>(),
            tokenCubit: context.read<TokenCubit>(),
          ),
        ),
        // BlocProvider<AppMonitoringCubit>(
        //   create: (context) => AppMonitoringCubit(
        //     examId: '674dc5ec874f97e70b0f1a2c',
        //     appLifecycleService: AppLifecycleService(),
        //     cheatingRepository: CheatingRepository(),
        //     tokenStorage: TokenStorage(),
        //     tokenCubit: context.read<TokenCubit>(),
        //   ),
        // ),
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
          '/forgot_password_view': (context) => ForgotPasswordView(),
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
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<SocketService>(
          create: (context) => socketService,
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => notificationService,
        ),
        RepositoryProvider<NotiRepository>(
          create: (context) => NotiRepository(),
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
              navigatorKey,
            ),
          ),
          BlocProvider<RealtimeCubit>(
            create: (context) => RealtimeCubit(
              tokenStorage,
              socketService,
              notificationService,
            ),
          ),
        ],
        child: MyApp()
      ),
    ),
  );
}