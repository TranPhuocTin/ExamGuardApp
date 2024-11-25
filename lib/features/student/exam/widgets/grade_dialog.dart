import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../cubit/grade_cubit.dart';
import '../cubit/grade_state.dart';
import '../../../../configs/app_colors.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class GradeDialog extends StatelessWidget {
  const GradeDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GradeCubit, GradeState>(
      builder: (context, state) {
        if (state is GradeLoading) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie/loading.json',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading score...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is GradeLoaded) {
          final score = state.score;
          final percentage = score / 10;
          
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    score >= 5 
                        ? 'assets/lottie/success.json'
                        : 'assets/lottie/fail.json',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 10.0,
                    percent: percentage,
                    center: Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    progressColor: _getColorForScore(score),
                    backgroundColor: Colors.grey[200]!,
                    animation: true,
                    animationDuration: 1500,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getMessageForScore(score),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitted at: ${_formatDateTime(state.createdAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        } else if (state is GradeError) {
          return AlertDialog(
            title: const Text('Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/error.json',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }
        return const AlertDialog(
          content: Text('Loading...'),
        );
      },
    );
  }

  Color _getColorForScore(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6.5) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  String _getMessageForScore(int score) {
    if (score >= 8) return 'Excellent! 🎉';
    if (score >= 6.5) return 'Good Job! 👏';
    if (score >= 5) return 'Passed! 👍';
    return 'Keep Trying! 💪';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute} ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
} 