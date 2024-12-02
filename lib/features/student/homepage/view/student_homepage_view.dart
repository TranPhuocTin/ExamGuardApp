import 'package:exam_guardian/features/common/cubit/base_homepage_cubit.dart';
import 'package:exam_guardian/features/student/profile/view/student_profile_page.dart';
import 'package:exam_guardian/features/student/grade/view/completed_grade_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../../../common/view/base_homepage_view.dart';
import 'package:exam_guardian/utils/widgets/global_error_handler.dart';
import 'package:exam_guardian/configs//app_colors.dart';

import '../../../common/widgets/custom_nav_bar.dart';
import '../../grade/bloc/completed_grade_cubit.dart';

class StudentHomepageView extends StatefulWidget {
  @override
  _StudentHomepageViewState createState() => _StudentHomepageViewState();
}

class _StudentHomepageViewState extends State<StudentHomepageView> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    StudentHomePage(),
    BlocProvider(
      create: (context) => CompletedGradeCubit(
        examRepository: context.read<ExamRepository>(),
        tokenStorage: context.read<TokenStorage>(),
        tokenCubit: context.read<TokenCubit>(),
      ),
      child: const CompletedGradeView(),
    ),
    StudentProfile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlobalErrorHandler(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        extendBody: true,
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            NavBarItem(icon: Icons.home_rounded, label: 'Home'),
            NavBarItem(icon: Icons.assignment_rounded, label: 'Grades'),
            NavBarItem(icon: Icons.person_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// Trang chủ cải tiến
class StudentHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BaseHomepageCubit(
        context.read<ExamRepository>(),
        context.read<TokenStorage>(),
        context.read<TokenCubit>(),
      )..loadInProgressExams(),
      child: BaseHomePageWrapper(),
    );
  }
}
