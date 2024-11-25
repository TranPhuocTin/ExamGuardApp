import 'package:exam_guardian/features/teacher/exams/view/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../../configs/app_animations.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../../../../utils/transitions/slide_up_route.dart';
import '../../../common/models/exam.dart';
import '../cubit/exam_cubit.dart';
import '../cubit/exam_state.dart';
import '../../../common/widgets/exam_card.dart';
import '../../../../configs/app_colors.dart';
import '../cubit/grade_list_cubit.dart';
import 'create_update_exam_view.dart';
import 'exam_detail_view.dart';
import '../view/grade_list_view.dart';

class ExamListPage extends StatefulWidget {
  @override
  _ExamListPageState createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  String _selectedStatus = 'All';
  List<String> _statusOptions = ['All', 'Scheduled', 'In Progress', 'Completed'];
  TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ExamCubit>().loadExams();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStatusFilter(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: _buildExamList(),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 65),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              SlideUpRoute(page: CreateUpdateExamView(filteredStatus: _selectedStatus != 'All' ? _selectedStatus : null)),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 180.0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/exam_guard_logo.png',
                        height: 40,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'ExamGuard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Exams',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your exams efficiently',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            // Handle notifications
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Search exams...',
        prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
        filled: true,
        fillColor: AppColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(30),
        //   borderSide: BorderSide(color: AppColors.primaryColor),
        // ),
      ),
      onTap: () {
        Navigator.push(context, SlideUpRoute(page: SearchView()));
      },
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusOptions.length,
        itemBuilder: (context, index) {
          final status = _statusOptions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: _selectedStatus == status,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = status;
                  });
                  context.read<ExamCubit>().loadExams(
                    status: status == 'All' ? null : status,
                    forceReload: true
                  );
                }
              },
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              backgroundColor: AppColors.backgroundWhite,
              labelStyle: TextStyle(
                color: _selectedStatus == status ? AppColors.primaryColor : AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamList() {
    return BlocBuilder<ExamCubit, ExamState>(
      builder: (context, state) {
        if (state is ExamInitial || (state is ExamLoading && state.isFirstFetch)) {
          return SliverFillRemaining(
            child: Center(child: Lottie.asset(AppAnimations.loading)),
          );
        } else if (state is ExamLoaded || (state is ExamLoading && !state.isFirstFetch)) {
          List<Exam> exams = [];
          bool isLoading = false;

          if (state is ExamLoaded) {
            exams = state.exams;
          } else if (state is ExamLoading) {
            exams = state.currentExams;
            isLoading = true;
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < exams.length) {
                  final exam = exams[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ExamCard(
                      exam: exam,
                      // isShowMoreIcon: exam.status != 'In Progress',
                      isShowMoreIcon: true,
                      isShowJoinButton: false,
                      onExamTapped: () {
                        if (exam.status == 'In Progress') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Không thể chỉnh sửa bài thi đang diễn ra'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ExamDetailView(exam: exam)
                          )
                        );
                      },
                      onViewGrades: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => GradeListCubit(
                                examRepository: context.read<ExamRepository>(),
                                tokenStorage: context.read<TokenStorage>(),
                                tokenCubit: context.read<TokenCubit>(),
                              ),
                              child: GradeListView(examId: exam.id ?? ''),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (isLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Lottie.asset(AppAnimations.loading)),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
              childCount: exams.length + (isLoading ? 1 : 0),
            ),
          );
        } else if (state is ExamError) {
          return SliverFillRemaining(
            child: Center(child: Text('Error: ${state.message}')),
          );
        } else {
          return SliverFillRemaining(
            child: Center(child: Text('No exams available')),
          );
        }
      },
    );
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ExamCubit>().loadMoreExams();
    }
  }
}
