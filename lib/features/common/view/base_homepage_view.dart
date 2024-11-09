import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
import 'package:exam_guardian/features/login/cubit/auth_state.dart';
import 'package:exam_guardian/features/student/homepage/view/student_exam_detail_view.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../teacher/exams/view/teacher_exam_monitoring_view.dart';
import '../widgets/exam_card.dart';
import '../../teacher/homepage/cubit/teacher_homepage_cubit.dart';
import '../cubit/base_homepage_cubit.dart';
import '../cubit/base_homepage_state.dart';
import '../models/exam.dart';

class BaseHomePageWrapper extends StatefulWidget {
  @override
  _BaseHomePageWrapperState createState() => _BaseHomePageWrapperState();
}

class _BaseHomePageWrapperState extends State<BaseHomePageWrapper> {
  @override
  Widget build(BuildContext context) {
    return BaseHomePageContent();
  }
}

class BaseHomePageContent extends StatefulWidget {
  @override
  _BaseHomePageContentState createState() => _BaseHomePageContentState();
}

class _BaseHomePageContentState extends State<BaseHomePageContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BaseHomepageCubit>().loadInProgressExams();
    }
  }

  void _onSearchChanged() {
    context.read<BaseHomepageCubit>().searchExams(_searchController.text);
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
          await context
              .read<BaseHomepageCubit>()
              .loadInProgressExams(forceReload: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.grey[100],
              elevation: 0,
              title:
                  Image.asset('assets/icons/exam_guard_logo.png', height: 40),
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
                    backgroundImage:
                        AssetImage('assets/images/teacher_avatar.png'),
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
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search active exams...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<BaseHomepageCubit>().resetSearch();
                          },
                        ),
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
            BlocBuilder<BaseHomepageCubit, BaseHomepageState>(
              builder: (context, state) {
                if (state is HomepageInitial) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is HomepageLoading) {
                  return _buildExamList(state.currentExams, isLoading: true);
                } else if (state is HomepageLoaded) {
                  return _buildExamList(state.exams,
                      hasReachedMax: state.hasReachedMax);
                } else if (state is HomepageError) {
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

  Widget _buildExamList(List<Exam> exams,
      {bool isLoading = false, bool hasReachedMax = false}) {
    return SliverPadding(
      padding: EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= exams.length) {
              if (isLoading) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (hasReachedMax) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: Text('No exam available')),
                );
              }
              return null;
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return ExamCard(
                    exam: exams[index],
                    isShowMoreIcon: false,
                    isShowJoinButton: state.user?.role == 'STUDENT' ? true : false,
                    onExamTapped: () async {
                      final role = await TokenStorage().getClientRole();
                      if (role == 'TEACHER') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherExamMonitoringView(exam: exams[index]),
                          ),
                        );
                      } else if (role == 'STUDENT') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Participation'),
                              content: Text('Are you sure you want to start this exam?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: Text('Confirm'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => StudentExamDetailView(exam: exams[index]),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
          childCount: exams.length + (isLoading || hasReachedMax ? 1 : 0),
        ),
      ),
    );
  }
}
