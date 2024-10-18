// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:exam_guardian/features/teacher/homepage/models/exam.dart';
// import 'package:exam_guardian/configs/app_colors.dart';
//
// class ExamCard extends StatelessWidget {
//   final Exam exam;
//
//   const ExamCard({Key? key, required this.exam}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       color: AppColors.cardBackground,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: () {
//           // Xử lý khi người dùng nhấn vào card
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 exam.title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(exam.description),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Start: ${DateFormat('MMM d, y HH:mm').format(exam.startTime)}',
//                     style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
//                   ),
//                   _buildStatusChip(exam.status),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusChip(String status) {
//     Color backgroundColor;
//     Color textColor;
//
//     switch (status.toLowerCase()) {
//       case 'scheduled':
//         backgroundColor = AppColors.primaryColor.withOpacity(0.2);
//         textColor = AppColors.primaryColor;
//         break;
//       case 'in progress':
//         backgroundColor = AppColors.success.withOpacity(0.2);
//         textColor = AppColors.success;
//         break;
//       case 'completed':
//         backgroundColor = AppColors.textSecondary.withOpacity(0.2);
//         textColor = AppColors.textSecondary;
//         break;
//       default:
//         backgroundColor = AppColors.textSecondary.withOpacity(0.2);
//         textColor = AppColors.textSecondary;
//     }
//
//     return Chip(
//       label: Text(status),
//       backgroundColor: backgroundColor,
//       labelStyle: TextStyle(color: textColor, fontSize: 12),
//     );
//   }
// }