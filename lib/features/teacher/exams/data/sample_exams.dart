// import 'package:intl/intl.dart';
// import '../../models/exam.dart';
//
//
// final List<Exam> sampleExams = [
//   Exam(
//     id: '1',
//     title: 'Math Midterm',
//     description: 'Algebra and Geometry',
//     startTime: DateTime.now().add(Duration(days: 7)),
//     endTime: DateTime.now().add(Duration(days: 7, hours: 2)),
//     status: 'Scheduled',
//     createdAt: DateTime.now().subtract(Duration(days: 30)),
//     updatedAt: DateTime.now().subtract(Duration(days: 2)),
//   ),
//   Exam(
//     id: '2',
//     title: 'Physics Quiz',
//     description: 'Mechanics and Thermodynamics',
//     startTime: DateTime.now().add(Duration(hours: 2)),
//     endTime: DateTime.now().add(Duration(hours: 3)),
//     status: 'In Progress',
//     createdAt: DateTime.now().subtract(Duration(days: 15)),
//     updatedAt: DateTime.now().subtract(Duration(days: 1)),
//   ),
//   Exam(
//     id: '3',
//     title: 'History Final',
//     description: 'World War II and Cold War',
//     startTime: DateTime.now().subtract(Duration(days: 1)),
//     endTime: DateTime.now().subtract(Duration(days: 1, hours: 3)),
//     status: 'Completed',
//     createdAt: DateTime.now().subtract(Duration(days: 45)),
//     updatedAt: DateTime.now().subtract(Duration(days: 2)),
//   ),
//   Exam(
//     id: '4',
//     title: 'Biology Lab Test',
//     description: 'Cell Structure and Function',
//     startTime: DateTime.now().add(Duration(days: 3)),
//     endTime: DateTime.now().add(Duration(days: 3, hours: 1, minutes: 30)),
//     status: 'Scheduled',
//     createdAt: DateTime.now().subtract(Duration(days: 10)),
//     updatedAt: DateTime.now().subtract(Duration(days: 1)),
//   ),
//   Exam(
//     id: '5',
//     title: 'English Literature Essay',
//     description: 'Shakespeare\'s Macbeth Analysis',
//     startTime: DateTime.now().add(Duration(days: 14)),
//     endTime: DateTime.now().add(Duration(days: 14, hours: 4)),
//     status: 'Scheduled',
//     createdAt: DateTime.now().subtract(Duration(days: 20)),
//     updatedAt: DateTime.now().subtract(Duration(hours: 12)),
//   ),
// ];
//
// String getFormattedDate(DateTime date) {
//   return DateFormat('yyyy-MM-dd HH:mm').format(date);
// }
