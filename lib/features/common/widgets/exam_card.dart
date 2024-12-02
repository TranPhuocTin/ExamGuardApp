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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Action Cards
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Edit Action
                    _buildActionCard(
                      onTap: () => _handleEdit(context),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.8),
                          AppColors.primaryColor,
                        ],
                      ),
                      icon: Icons.edit_rounded,
                      title: 'Edit Exam',
                      subtitle: 'Modify exam details and settings',
                    ),
                    const SizedBox(height: 12),

                    // View Grades Action
                    _buildActionCard(
                      onTap: () => onViewGrades?.call(),
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange[400]!,
                          Colors.orange[600]!,
                        ],
                      ),
                      icon: Icons.analytics_rounded,
                      title: 'View Grades',
                      subtitle: 'Check student performance',
                    ),
                    const SizedBox(height: 12),

                    // Delete Action
                    _buildActionCard(
                      onTap: () => _handleDelete(context),
                      gradient: LinearGradient(
                        colors: [
                          Colors.red[400]!,
                          Colors.red[600]!,
                        ],
                      ),
                      icon: Icons.delete_rounded,
                      title: 'Delete Exam',
                      subtitle: 'Remove this exam permanently',
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              
              // Close Button
        
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required VoidCallback onTap,
    required Gradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDestructive 
                  ? Colors.red.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
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
