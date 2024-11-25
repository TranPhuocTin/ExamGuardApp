import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_colors.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../cubit/grade_list_cubit.dart';
import '../cubit/grade_list_state.dart';
import '../model/grade_list_response.dart';

class GradeListView extends StatefulWidget {
  final String examId;

  const GradeListView({required this.examId, Key? key}) : super(key: key);

  @override
  State<GradeListView> createState() => _GradeListViewState();
}

class _GradeListViewState extends State<GradeListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<GradeListCubit>().loadGrades(examId: widget.examId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<GradeListCubit>().loadGrades(
        examId: widget.examId,
        isLoadMore: true,
      );
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
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(
          'Student Grades',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: BlocBuilder<GradeListCubit, GradeListState>(
        builder: (context, state) {
          print('Current state: $state');

          if (state is GradeListLoading && state.isFirstFetch) {
            return Center(child: CircularProgressIndicator());
          }

          List<GradeDetail> grades = [];
          bool isLoading = false;

          if (state is GradeListLoading) {
            grades = state.currentGrades;
            isLoading = true;
          } else if (state is GradeListLoaded) {
            grades = state.grades;
          } else if (state is GradeListError) {
            return Center(child: Text(state.message));
          }

          if (grades.isEmpty) {
            return Center(child: Text('No grades available'));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(16),
            itemCount: grades.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < grades.length) {
                return _buildGradeCard(grades[index]);
              } else if (isLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }

  Widget _buildGradeCard(GradeDetail grade) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(grade.student.avatar),
                  radius: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grade.student.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        grade.student.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildScoreIndicator(grade.score),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
            _buildTimestamps(grade),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(int score) {
    final color = _getScoreColor(score);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          score.toString(),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6.5) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTimestamps(GradeDetail grade) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimestamp('Submitted', grade.createdAt),
        _buildTimestamp('Updated', grade.updatedAt),
      ],
    );
  }

  Widget _buildTimestamp(String label, DateTime timestamp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        Text(
          DateFormat('dd/MM/yyyy HH:mm').format(timestamp),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}