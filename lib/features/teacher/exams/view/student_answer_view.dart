import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/app_colors.dart';
import '../../../../data/exam_repository.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../utils/share_preference/token_cubit.dart';
import '../cubit/student_answer_cubit.dart';
import '../cubit/student_answer_state.dart';
import '../model/student_answer_response.dart';

class StudentAnswerView extends StatefulWidget {
  final String examId;
  final String studentId;
  final String studentName;

  const StudentAnswerView({
    Key? key,
    required this.examId,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<StudentAnswerView> createState() => _StudentAnswerViewState();
}

class _StudentAnswerViewState extends State<StudentAnswerView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<StudentAnswerCubit>().loadStudentAnswers(
            widget.examId,
            widget.studentId,
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
    return BlocProvider(
      create: (context) => StudentAnswerCubit(
        examRepository: context.read<ExamRepository>(),
        tokenStorage: context.read<TokenStorage>(),
        tokenCubit: context.read<TokenCubit>(),
      )..loadStudentAnswers(widget.examId, widget.studentId),
      child: Scaffold(
        extendBody: false,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildCustomAppBar(context),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FAFF),  // Xanh dương rất nhạt
                Colors.white,        // Trắng
              ],
              stops: const [0.0, 0.9],
            ),
          ),
          child: BlocBuilder<StudentAnswerCubit, StudentAnswerState>(
            builder: (context, state) {
              return _buildContent(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Student Answers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StudentAnswerState state) {
    if (state is StudentAnswerInitial) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is StudentAnswerError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(state.message),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<StudentAnswerCubit>().loadStudentAnswers(
                      widget.examId,
                      widget.studentId,
                      refresh: true,
                    );
              },
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    List<StudentAnswer> answers = [];
    bool isLoading = false;

    if (state is StudentAnswerLoading) {
      answers = state.currentAnswers;
      isLoading = true;
    } else if (state is StudentAnswerLoaded) {
      answers = state.answers;
    }

    if (answers.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có câu trả lời nào'),
          ],
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= answers.length) {
                  return isLoading
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SizedBox();
                }

                final answer = answers[index];
                return _buildAnswerCard(answer);
              },
              childCount: answers.length + (isLoading ? 1 : 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerCard(StudentAnswer answer) {
    final isCorrect = answer.isCorrect;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Câu hỏi:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              answer.question.questionText,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Câu trả lời của học sinh:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      answer.answerText,
                      style: TextStyle(
                        fontSize: 16,
                        color: isCorrect ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (answer.question.correctAnswer != null) ...[
              SizedBox(height: 16),
              Text(
                'Đáp án đúng:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  answer.question.correctAnswer!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
