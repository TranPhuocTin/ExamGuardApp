import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/app_colors.dart';
import '../../../../data/cheating_repository.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/mixins/infinite_scroll_mixin.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../../../common/models/exam.dart';
import '../../../common/models/question_response.dart';
import '../../exam_monitoring/view/face_monitoring_view.dart';
import '../../exam_monitoring/cubit/face_monitoring_cubit.dart';
import '../cubit/student_exam_cubit.dart';
import '../cubit/student_exam_state.dart';
import '../cubit/answer_submission_cubit.dart';
import '../cubit/answer_submission_state.dart';

class StudentExamDetailView extends StatefulWidget {
  final Exam exam;

  const StudentExamDetailView({Key? key, required this.exam}) : super(key: key);

  @override
  State<StudentExamDetailView> createState() => _StudentExamDetailViewState();
}

class _StudentExamDetailViewState extends State<StudentExamDetailView> with InfiniteScrollMixin {
  final Map<String, String> selectedAnswers = {};
  late final StudentExamCubit _examCubit;

  @override
  void initState() {
    super.initState();
  }

  @override
  void onLoadMore() {
    if (_examCubit == null) return;
    
    final state = _examCubit.state;
    if (state is StudentExamLoaded && !state.hasReachedMax && !state.isLoading) {
      _examCubit.loadMoreQuestions();
    }
  }

  @override
  void dispose() {
    _examCubit.close();
    super.dispose();
  }

  Widget _buildTimer() {
    return BlocBuilder<StudentExamCubit, StudentExamState>(
      builder: (context, state) {
        if (state is StudentExamLoaded) {
          final minutes = state.remainingTime.minutes.toString().padLeft(2, '0');
          final seconds = state.remainingTime.seconds.toString().padLeft(2, '0');
          
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Text(
                  '$minutes:$seconds',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StudentExamCubit>(
          create: (context) {
            final cubit = StudentExamCubit(
              examRepository: context.read<ExamRepository>(),
              tokenStorage: context.read<TokenStorage>(),
              examId: widget.exam.id!,
            );
            _examCubit = cubit;
            cubit.loadExam();
            return cubit;
          },
        ),
        BlocProvider<AnswerSubmissionCubit>(
          create: (context) => AnswerSubmissionCubit(
            examRepository: context.read<ExamRepository>(),
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),
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
        body: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: [
                // Custom SliverAppBar
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  expandedHeight: 60.0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.exam.title,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    BlocBuilder<StudentExamCubit, StudentExamState>(
                      builder: (context, state) {
                        if (state is StudentExamLoaded) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildTimer(),
                          );
                        }
                        return SizedBox();
                      },
                    ),
                  ],
                ),

                // Questions List
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: BlocBuilder<StudentExamCubit, StudentExamState>(
                    builder: (context, state) {
                      if (state is StudentExamLoading) {
                        return SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is StudentExamLoaded) {
                        final questions = state.questions;
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < questions.length) {
                                return _buildQuestionCard(questions[index], index);
                              } else if (!state.hasReachedMax) {
                                return Center(child: CircularProgressIndicator());
                              }
                              return null;
                            },
                            childCount: questions.length + (state.hasReachedMax ? 0 : 1),
                          ),
                        );
                      }

                      return SliverToBoxAdapter(
                        child: Center(child: Text('No questions available')),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Face Monitoring View
            FaceMonitoringView(examId: widget.exam.id!),
          ],
        ),
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

    return BlocBuilder<AnswerSubmissionCubit, AnswerSubmissionState>(
      builder: (context, state) {
        return InkWell(
          onTap: () async {
            // Cập nhật UI trước
            setState(() {
              if (isSelected) {
                selectedAnswers.remove(question.id);
              } else {
                selectedAnswers[question.id!] = option;
              }
            });

            // Submit answer thông qua cubit
            await context.read<AnswerSubmissionCubit>().submitAnswer(
              question.id!,
              option,
            );
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
      },
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

  void _submitAnswers() async {
    try {
      for (var entry in selectedAnswers.entries) {
        await context.read<StudentExamCubit>().submitAnswer(
          entry.key,
          entry.value,
        );
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nộp bài thành công')),
      );
      Navigator.of(context).pop(); // Return to previous screen
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi nộp bài')),
      );
    }
  }
}
