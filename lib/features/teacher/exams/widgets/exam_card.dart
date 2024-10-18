import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/exam.dart';
import '../../../../configs/app_colors.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;

  const ExamCard({Key? key, required this.exam}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Xử lý khi người dùng nhấn vào card
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
              SizedBox(height: 16),
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
                  IconButton(
                    icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                    onPressed: () {
                      // Hiển thị menu tùy chọn
                    },
                  ),
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
}
