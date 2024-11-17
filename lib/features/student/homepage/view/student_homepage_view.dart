import 'package:exam_guardian/features/common/cubit/base_homepage_cubit.dart';
import 'package:exam_guardian/features/student/profile/view/student_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../../../common/view/base_homepage_view.dart';
import 'package:exam_guardian/utils/widgets/global_error_handler.dart';

class StudentHomepageView extends StatefulWidget {
  @override
  _StudentHomepageViewState createState() => _StudentHomepageViewState();
}

class _StudentHomepageViewState extends State<StudentHomepageView> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    StudentHomePage(),
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
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.indigo[800],
          onTap: _onItemTapped,
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
