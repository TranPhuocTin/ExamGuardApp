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

  const ExamCard({
    Key? key,
    required this.exam,
    required this.isShowMoreIcon,
    required this.isShowJoinButton,
    this.onExamUpdated,
    this.onExamTapped
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          onExamTapped!();
        },
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildStatusChip(exam.status),
                ],
              ),
              SizedBox(height: 8),
              Text(
                exam.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${exam.questionCount ?? 0} questions',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Start: ${_formatTime(exam.startTime)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 20,),
                      Text(
                        'Due: ${_formatTime(exam.endTime)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  isShowMoreIcon ? IconButton(
                    icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onPressed: () => _showOptions(context),
                  ) : isShowJoinButton ? TextButton(onPressed: () {
                    
                  }, child: Text('Join', style: TextStyle(color: AppColors.viewButton, fontSize: 12),)  ) : TextButton(onPressed: () {
                    
                  }, child: Text('View', style: TextStyle(color: AppColors.viewButton, fontSize: 12),))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'scheduled':
        backgroundColor = AppColors.primaryColor.withOpacity(0.2);
        textColor = AppColors.primaryColor;
        break;
      case 'in progress':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case 'completed':
        backgroundColor = AppColors.textSecondary.withOpacity(0.2);
        textColor = AppColors.textSecondary;
        break;
      default:
        backgroundColor = AppColors.textSecondary.withOpacity(0.2);
        textColor = AppColors.textSecondary;
    }

    return Chip(
      label: Text(status),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor, fontSize: 12),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.primaryColor),
                title: Text('Edit'),
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateUpdateExamView(exam: exam)),
                  );
                  if (result == true && onExamUpdated != null) {
                    onExamUpdated!();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility, color: AppColors.primaryColor),
                title: Text('View'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExamDetailView(exam: exam)));
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
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
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
