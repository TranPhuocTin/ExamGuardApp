import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/app_colors.dart';
import '../../../../data/cheating_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../../../common/models/exam.dart';
import '../../../common/models/question_response.dart';
import '../../../teacher/exams/cubit/question_cubit.dart';
import '../../../teacher/exams/cubit/question_state.dart';
import '../../exam_monitoring/view/face_monitoring_view.dart';
import '../../exam_monitoring/cubit/face_monitoring_cubit.dart';

class StudentExamDetailView extends StatefulWidget {
  final Exam exam;

  const StudentExamDetailView({Key? key, required this.exam}) : super(key: key);

  @override
  State<StudentExamDetailView> createState() => _StudentExamDetailViewState();
}

class _StudentExamDetailViewState extends State<StudentExamDetailView> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    context.read<QuestionCubit>().loadQuestions(examId: widget.exam.id!);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FaceMonitoringCubit>(
          create: (context) => FaceMonitoringCubit(
            examId: widget.exam.id!,
            cheatingRepository: context.read<CheatingRepository>(),
            tokenStorage: context.read<TokenStorage>(),
            tokenCubit: context.read<TokenCubit>(),
          ),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: BlocBuilder<QuestionCubit, QuestionState>(
                      builder: (context, state) {
                        if (state is QuestionLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is QuestionError) {
                          return Center(child: Text(state.message));
                        }

                        if (state is QuestionLoaded) {
                          final questions = state.questions;
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: questions.length + 1,
                            itemBuilder: (context, index) {
                              if (index < questions.length) {
                                return _buildQuestionCard(
                                    questions[index], index);
                              } else {
                                return _buildSubmitButton();
                              }
                            },
                          );
                        }

                        return const Center(
                            child: Text('No questions available'));
                      },
                    ),
                  ),
                ],
              ),
              // Draggable monitoring view
              FaceMonitoringView(examId: widget.exam.id!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Leave Exam?'),
                  content: const Text(
                    'Are you sure you want to leave? Your progress will be saved automatically.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: const Text('Leave'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          // Centered title
          Expanded(
            child: Text(
              widget.exam.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer to balance the back button
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    'Q${index + 1}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.questionType,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...question.options
                .map((option) => _buildAnswerOption(option, question))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String option, Question question) {
    bool isSelected = selectedAnswers[question.id] == option;

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedAnswers.remove(question.id);
          } else {
            selectedAnswers[question.id!] = option;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primaryColor : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: _submitAnswers,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Submit Answers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _submitAnswers() {
    final submissions = selectedAnswers.entries.map((entry) {
      return {
        'questionId': entry.key,
        'selectedAnswer': entry.value,
      };
    }).toList();

    // context.read<QuestionCubit>().submitAnswers(widget.exam.id!, submissions);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
