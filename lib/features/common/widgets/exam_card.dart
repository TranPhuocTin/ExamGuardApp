import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../utils/transitions/slide_up_route.dart';
import '../models/exam.dart';
import '../../../configs/app_colors.dart';
import '../../teacher/exams/cubit/exam_cubit.dart';
import '../../teacher/exams/view/create_update_exam_view.dart';
import '../../teacher/exams/view/exam_detail_view.dart';
import 'delete_confirm_dialog.dart';

class ExamCard extends StatelessWidget {
  final bool isShowMoreIcon;
  final bool isShowJoinButton;
  final Exam exam;
  final VoidCallback? onExamUpdated;
  final VoidCallback? onExamTapped;
  final VoidCallback? onViewGrades;

  const ExamCard({
    Key? key,
    required this.exam,
    required this.isShowMoreIcon,
    required this.isShowJoinButton,
    this.onExamUpdated,
    this.onExamTapped,
    this.onViewGrades,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: _getStatusGradient(exam.status),
            ),
          ),
          Ink(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: InkWell(
              onTap: onExamTapped,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exam.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                        _buildStatusBadge(exam.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      exam.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(),
                    const SizedBox(height: 12),
                    _buildProgressIndicator(),
                    const SizedBox(height: 12),
                    _buildTimeAndActions(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'scheduled':
        backgroundColor = AppColors.primaryColor.withOpacity(0.1);
        textColor = AppColors.primaryColor;
        break;
      case 'in progress':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        break;
      case 'completed':
        backgroundColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
        break;
      default:
        backgroundColor = AppColors.textSecondary.withOpacity(0.1);
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildInfoItem(
          Icons.quiz_outlined,
          '${exam.questionCount ?? 0} questions',
        ),
        const SizedBox(width: 16),
        _buildInfoItem(
          Icons.timer_outlined,
          exam.duration != null ? '${exam.duration} minutes' : 'No time limit',
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    // Calculate progress based on current time and exam duration
    double progress = 0.0;
    final now = DateTime.now();

    if (now.isAfter(exam.startTime) && now.isBefore(exam.endTime)) {
      final totalDuration = exam.endTime.difference(exam.startTime);
      final elapsed = now.difference(exam.startTime);
      progress = elapsed.inMinutes / totalDuration.inMinutes;
    } else if (now.isAfter(exam.endTime)) {
      progress = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            exam.status.toLowerCase() == 'completed'
                ? AppColors.textSecondary
                : AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start: ${_formatTime(exam.startTime)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Due: ${_formatTime(exam.endTime)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeAndActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isShowMoreIcon)
          InkWell(
            onTap: () => _showOptions(context),
            child: Padding(
              padding: EdgeInsets.all(0),
              child: Icon(Icons.more_vert, color: AppColors.textSecondary),
            ),
          )
        // else if (isShowJoinButton)
        //   _buildActionButton('Join', AppColors.primaryColor)
        // else
        //   _buildActionButton('View', AppColors.viewButton),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color) {
    return TextButton(
      onPressed: onExamTapped,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildOptionItem(
                context,
                icon: Icons.edit,
                title: 'Edit',
                color: AppColors.primaryColor,
                onTap: () => _handleEdit(context),
              ),
              _buildOptionItem(
                context,
                icon: Icons.visibility,
                title: 'View',
                color: AppColors.primaryColor,
                onTap: () => _handleView(context),
              ),
              _buildOptionItem(
                context,
                icon: Icons.delete,
                title: 'Delete',
                color: Colors.red,
                onTap: () => _handleDelete(context),
              ),
              _buildOptionItem(
                context,
                icon: Icons.grade,
                title: 'View Grades',
                color: AppColors.primaryColor,
                onTap: () => onViewGrades?.call(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _handleEdit(BuildContext context) async {
    Navigator.pop(context);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateUpdateExamView(exam: exam),
      ),
    );
    if (result == true && onExamUpdated != null) {
      onExamUpdated!();
    }
  }

  void _handleView(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamDetailView(exam: exam),
      ),
    );
  }

  void _handleDelete(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          examTitle: exam.title,
          onConfirm: () async {
            await context.read<ExamCubit>().deleteExam(exam.id!, exam.status);
          },
        );
      },
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.scheduledGradient;
      case 'in progress':
        return AppColors.inProgressGradient;
      case 'completed':
        return AppColors.completedGradient;
      default:
        return AppColors.completedGradient;
    }
  }
}
