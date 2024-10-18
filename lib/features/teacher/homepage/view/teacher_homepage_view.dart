import 'dart:async';

import 'package:exam_guardian/features/teacher/exams/data/sample_exams.dart';
import 'package:exam_guardian/features/teacher/profile/view/teacher_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exam_guardian/features/teacher/exams/cubit/exam_cubit.dart';
import 'package:exam_guardian/features/teacher/exams/cubit/exam_state.dart';
import 'package:exam_guardian/features/teacher/exams/widgets/exam_card.dart';
import 'package:exam_guardian/configs/app_colors.dart';

import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../admin/models/user_response.dart';
import '../../exams/view/exam_page.dart';
import '../../exams/widgets/exam_card.dart';
import '../../models/exam.dart';
import '../cubit/teacher_homepage_state.dart';
import '../widgets/exam_card.dart';
import 'package:exam_guardian/features/teacher/homepage/cubit/teacher_homepage_cubit.dart';

class TeacherHomepageView extends StatefulWidget {
  @override
  _TeacherHomepageViewState createState() => _TeacherHomepageViewState();
}

class _TeacherHomepageViewState extends State<TeacherHomepageView> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    TeacherHomePage(),
    ExamListPage(),
    TeacherProfilePage(
      teacher: User(
        id: '1',
        username: 'john_doe',
        name: 'John Doe',
        email: 'john.doe@example.com',
        role: 'TEACHER',
        avatar: 'https://example.com/avatars/john_doe.jpg',
        gender: 'MALE',
        ssn: 123456789,
        dob: DateTime(1980, 5, 15),
        address: '123 Main St, Anytown, USA',
        phone_number: '+1 (555) 123-4567',
        status: 'ACTIVE',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 6, 1),
      ),
    )
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Exams',
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
    );
  }
}

// Trang chủ cải tiến
class TeacherHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeacherHomepageCubit(
        context.read<ExamRepository>(),
        context.read<TokenStorage>(),
      )..loadInProgressExams(),
      child: TeacherHomePageWrapper(),
    );
  }
}

class TeacherHomePageWrapper extends StatefulWidget {
  @override
  _TeacherHomePageWrapperState createState() => _TeacherHomePageWrapperState();
}

class _TeacherHomePageWrapperState extends State<TeacherHomePageWrapper> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _checkAndRefresh();
    });
  }

  void _checkAndRefresh() {
    final teacherHomepageCubit = context.read<TeacherHomepageCubit>();
    final currentState = teacherHomepageCubit.state;
    if (currentState is TeacherHomepageLoaded) {
      final now = DateTime.now();
      bool shouldRefresh = currentState.exams.any((exam) {
        return exam.endTime!.isAfter(now) && exam.endTime!.difference(now).inMinutes <= 1;
      });

      if (shouldRefresh) {
        teacherHomepageCubit.loadInProgressExams(forceReload: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeacherHomePageContent();
  }
}

class TeacherHomePageContent extends StatefulWidget {
  @override
  _TeacherHomePageContentState createState() => _TeacherHomePageContentState();
}

class _TeacherHomePageContentState extends State<TeacherHomePageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    print('TeacherHomePageContent initialized');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    print('TeacherHomePageContent disposed');
  }

  void _onScroll() {
    if (_isBottom) {
      print('Reached bottom of the list, loading more exams');
      context.read<TeacherHomepageCubit>().loadInProgressExams();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () async {
          print('Manual refresh triggered');
          await context.read<TeacherHomepageCubit>().loadInProgressExams(forceReload: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Image.asset('assets/icons/exam_guard_logo.png', height: 40),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.grey[800]),
                  onPressed: () {
                    // Hiển thị thông báo
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/teacher_avatar.png'),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Teacher!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search active exams...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<TeacherHomepageCubit, TeacherHomepageState>(
              builder: (context, state) {
                print('Current state: $state');
                if (state is TeacherHomepageInitial) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is TeacherHomepageLoading) {
                  return _buildExamList(state.currentExams, isLoading: true);
                } else if (state is TeacherHomepageLoaded) {
                  return _buildExamList(state.exams, hasReachedMax: state.hasReachedMax);
                } else if (state is TeacherHomepageError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return SliverToBoxAdapter(child: Container());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamList(List<Exam> exams, {bool isLoading = false, bool hasReachedMax = false}) {
    print('Building exam list: ${exams.length} exams, isLoading: $isLoading, hasReachedMax: $hasReachedMax');
    return SliverPadding(
      padding: EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= exams.length) {
              if (isLoading) {
                print('Showing loading indicator at the bottom');
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (hasReachedMax) {
                print('Showing "No more exams" message');
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: Text('No more exams')),
                );
              }
              return null;
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: ExamCard(exam: exams[index]),
            );
          },
          childCount: exams.length + (isLoading || hasReachedMax ? 1 : 0),
        ),
      ),
    );
  }
}
