import 'package:exam_guardian/configs/app_animations.dart';
import 'package:exam_guardian/features/login/cubit/auth_cubit.dart';
import 'package:exam_guardian/features/login/cubit/auth_state.dart';
import 'package:exam_guardian/features/student/exam/view/student_exam_detail_view.dart';
import 'package:exam_guardian/screen_info_app.dart';
import 'package:exam_guardian/utils/share_preference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shimmer/shimmer.dart';

import '../../../configs/app_colors.dart';
import '../../../data/cheating_repository.dart';
import '../../../data/exam_repository.dart';
import '../../../utils/share_preference/token_cubit.dart';
import '../../student/exam/cubit/grade_cubit.dart';
import '../../student/exam/cubit/student_exam_cubit.dart';
import '../../student/exam/widgets/grade_dialog.dart';
import '../../student/exam_monitoring/cubit/face_monitoring_cubit.dart';
import '../../teacher/exams/view/teacher_exam_monitoring_view.dart';
import '../widgets/exam_card.dart';
import '../cubit/base_homepage_cubit.dart';
import '../cubit/base_homepage_state.dart';
import '../models/exam.dart';
import '../widgets/exam_card_shimmer.dart';
import '../widgets/avatar_widget.dart';
import '../notifications/view/notifications_view.dart';
import '../notifications/cubit/notification_cubit.dart';
import '../../../data/noti_repository.dart';

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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && mounted) {
      final cubit = context.read<BaseHomepageCubit>();
      if (!cubit.isClosed) {
        cubit.loadInProgressExams();
      }
    }
  }

  void _onSearchChanged() {
    if (mounted) {
      final cubit = context.read<BaseHomepageCubit>();
      if (!cubit.isClosed) {
        cubit.searchExams(_searchController.text);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Widget _buildExamList(List<Exam> exams,
      {bool isLoading = false, bool hasReachedMax = false}) {
    if (exams.isEmpty && !isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Text('No exam available'),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= exams.length) {
              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: ExamCardShimmer(),
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
                    isShowJoinButton:
                        state.user?.role == 'STUDENT' ? true : false,
                    onExamTapped: () async {
                      try {
                        if (state.user?.role == 'TEACHER') {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TeacherExamMonitoringView(exam: exams[index]),
                              fullscreenDialog: true,
                            ),
                          );
                        } else if (state.user?.role == 'STUDENT') {
                          final studentExamCubit = StudentExamCubit(
                            examRepository: context.read<ExamRepository>(),
                            tokenStorage: context.read<TokenStorage>(),
                            tokenCubit: context.read<TokenCubit>(),
                            examId: exams[index].id!,
                          );

                          await studentExamCubit.loadExam();

                          if (!mounted) return;

                          final currentContext = _navigatorKey.currentContext;
                          if (currentContext == null) return;

                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider<StudentExamCubit>.value(
                                          value: studentExamCubit,
                                        ),
                                        BlocProvider<FaceMonitoringCubit>(
                                          create: (context) =>
                                              FaceMonitoringCubit(
                                            examId: exams[index].id!,
                                            cheatingRepository: context
                                                .read<CheatingRepository>(),
                                            tokenStorage:
                                                context.read<TokenStorage>(),
                                            tokenCubit:
                                                context.read<TokenCubit>(),
                                          ),
                                        ),
                                      ],
                                      child: StudentExamDetailView(
                                          exam: exams[index]),
                                    ),
                                fullscreenDialog: true),
                          );
                        }
                      } catch (e) {
                        final currentContext = _navigatorKey.currentContext;
                        if (currentContext != null && mounted) {
                          showDialog(
                            context: currentContext,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Thông báo'),
                                content: Text(e.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context
                                          .read<GradeCubit>()
                                          .getGrade(exams[index].id!);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            const GradeDialog(),
                                      );
                                    },
                                    child: const Text('Xem điểm'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                  );
                },
              ),
            );
          },
          childCount: exams.length + (isLoading ? 1 : 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: AppColors.backgroundGrey,
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
                    pinned: true,
                    expandedHeight: 220,
                    backgroundColor: Colors.white,
                    elevation: 2,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor,
                              AppColors.secondaryColor,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      'assets/icons/exam_guard_logo.png',
                                      height: 35,
                                      color: Colors.white,
                                    ),
                                    BlocBuilder<AuthCubit, AuthState>(
                                      builder: (context, state) {
                                        return Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.notifications_none,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BlocProvider(
                                                          create: (context) =>
                                                              NotificationListCubit(
                                                                RepositoryProvider.of<NotiRepository>(context),
                                                                RepositoryProvider.of<TokenStorage>(context),
                                                                BlocProvider.of<TokenCubit>(context),
                                                              )..fetchNotifications(),
                                                          child: const NotificationsView(),
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                // Handle profile tap
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: AvatarWidget(
                                                  avatarUrl: state.user?.avatar,
                                                  radius: 18,
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 24, 16, 20),
                                  child: BlocBuilder<AuthCubit, AuthState>(
                                    builder: (context, state) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome back,',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            state.user?.role == 'TEACHER'
                                                ? state.user?.name ?? ""
                                                : state.user?.name ?? "",
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      collapseMode: CollapseMode.pin,
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.fromLTRB(5, 5, 5  , 5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search active exams...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            // suffixIcon: IconButton(
                            //   icon: const Icon(Icons.clear, color: Colors.grey),
                            //   onPressed: () {
                            //     _searchController.clear();
                            //     context.read<BaseHomepageCubit>().resetSearch();
                            //   },
                            // ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<BaseHomepageCubit, BaseHomepageState>(
                    builder: (context, state) {
                      if (state is HomepageInitial) {
                        return SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const ExamCardShimmer(),
                              childCount: 3,
                            ),
                          ),
                        );
                      }

                      if (state is HomepageError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(state.message),
                          ),
                        );
                      }

                      final exams = (state is HomepageLoaded
                          ? state.exams
                          : state is HomepageLoading
                              ? state.currentExams
                              : <Exam>[]) as List<Exam>;

                      return _buildExamList(
                        exams,
                        isLoading: state is HomepageLoading,
                        hasReachedMax: state is HomepageLoaded
                            ? state.hasReachedMax
                            : false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
