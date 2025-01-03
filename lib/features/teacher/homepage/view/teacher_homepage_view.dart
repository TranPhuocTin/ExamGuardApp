import 'dart:async';

import 'package:exam_guardian/features/common/cubit/base_homepage_cubit.dart';
import 'package:exam_guardian/features/teacher/profile/view/teacher_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/socket_service.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../../../common/view/base_homepage_view.dart';
import '../../../notification/cubit/notification_cubit.dart';
import '../../../notification/cubit/notification_state.dart';
import '../../../realtime/cubit/realtime_cubit.dart';
import '../../exams/cubit/cheating_statistics_cubit.dart';
import '../../exams/view/exam_page.dart';
import 'package:exam_guardian/utils/widgets/global_error_handler.dart';
import 'package:exam_guardian/configs/app_colors.dart';
import '../../../common/widgets/custom_nav_bar.dart';

class TeacherHomepageView extends StatefulWidget {
  @override
  _TeacherHomepageViewState createState() => _TeacherHomepageViewState();
}

class _TeacherHomepageViewState extends State<TeacherHomepageView> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo socket khi vào homepage
    context.read<RealtimeCubit>().initializeSocket();
  }

  static List<Widget> _widgetOptions = <Widget>[
    TeacherHomePage(),
    ExamListPage(),
    TeacherProfile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationCubit, NotificationState>(
      listener: (context, state) {
        // Xử lý notification tại đây
      },
      child: GlobalErrorHandler(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          extendBody: true,
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: CustomNavBar(
            selectedIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              NavBarItem(icon: Icons.home_rounded, label: 'Home'),
              NavBarItem(icon: Icons.assignment_rounded, label: 'Exams'),
              NavBarItem(icon: Icons.person_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return BlocProvider(
    //   create: (context) => BaseHomepageCubit(
    //     context.read<ExamRepository>(),
    //     context.read<TokenStorage>(),
    //     context.read<TokenCubit>(),
    //   )..loadInProgressExams(),
    //   child: BaseHomePageWrapper(),
    // );
    return MultiBlocProvider(
        providers: [
    BlocProvider(
          create: (context) => BaseHomepageCubit(
            context.read<ExamRepository>(),
            context.read<TokenStorage>(),
            context.read<TokenCubit>(),
          )..loadInProgressExams(),
        ),
        ],
        child: BaseHomePageWrapper(),
      );
  }
}
