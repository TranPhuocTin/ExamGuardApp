import 'package:exam_guardian/features/student/grade/bloc/completed_grade_cubit.dart';
import 'package:exam_guardian/features/student/grade/bloc/completed_grade_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:exam_guardian/configs/app_colors.dart';
import 'package:exam_guardian/features/student/grade/widgets/completed_grade_shimmer.dart';

class CompletedGradeView extends StatefulWidget {
  const CompletedGradeView({Key? key}) : super(key: key);

  @override
  State<CompletedGradeView> createState() => _CompletedGradeViewState();
}

class _CompletedGradeViewState extends State<CompletedGradeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CompletedGradeCubit>().fetchCompletedGrades();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CompletedGradeCubit>().fetchMoreCompletedGrades();
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
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
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completed Grades',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'View your exam results',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              // Handle filter action
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(15),
          child: Container(
            height: 15,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<CompletedGradeCubit, CompletedGradeState>(
        builder: (context, state) {
          if (state.status == CompletedGradeStatus.loading && state.grades.isEmpty) {
            return const CompletedGradeShimmer();
          }

          if (state.status == CompletedGradeStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: TextStyle(color: Colors.red[300]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CompletedGradeCubit>().fetchCompletedGrades();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state.grades.isEmpty) {
            return const Center(
              child: Text('No completed grades yet'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CompletedGradeCubit>().fetchCompletedGrades();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.hasReachedMax 
                ? state.grades.length 
                : state.grades.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.grades.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final grade = state.grades[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // Handle tap if needed
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(grade.score).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getScoreIcon(grade.score),
                                    color: _getScoreColor(grade.score),
                                    size: 24,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    grade.exam?.title ?? 'Unknown Exam',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _getScoreColor(grade.score),
                                        _getScoreColor(grade.score).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getScoreColor(grade.score).withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${grade.score}/10',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            Row(
                              children: [
                                _buildInfoItem(
                                  Icons.calendar_today,
                                  'Date',
                                  DateFormat('dd/MM/yyyy').format(grade.createdAt),
                                ),
                                const SizedBox(width: 24),
                                _buildInfoItem(
                                  Icons.access_time,
                                  'Time',
                                  DateFormat('HH:mm').format(grade.createdAt),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoItem(
                              Icons.person_outline,
                              'Teacher',
                              grade.exam?.teacher ?? 'Unknown Teacher',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6.5) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 8) return Icons.emoji_events;
    if (score >= 6.5) return Icons.thumb_up;
    if (score >= 5) return Icons.check_circle;
    return Icons.warning;
  }
}
