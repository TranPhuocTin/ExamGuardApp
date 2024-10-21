import 'package:flutter/material.dart';
import 'package:exam_guardian/features/teacher/models/exam.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../configs/app_colors.dart';
import '../../models/question_response.dart';
import '../cubit/question_cubit.dart';
import '../cubit/question_state.dart';
import '../view/add_question_view.dart';
import '../widgets/delete_confirm_dialog.dart';

class ExamDetailView extends StatefulWidget {
  final Exam exam;

  const ExamDetailView({Key? key, required this.exam}) : super(key: key);

  @override
  _ExamDetailViewState createState() => _ExamDetailViewState();
}

class _ExamDetailViewState extends State<ExamDetailView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<QuestionCubit>().loadQuestions(examId: widget.exam.id!);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<QuestionCubit>().loadMoreQuestions();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  late List<Question> questions;
  bool _expandAll = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: BlocBuilder<QuestionCubit, QuestionState>(
                builder: (context, state) {
                  if (state is QuestionLoading && state.isFirstFetch) {
                    return SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  List<Question> questions = [];
                  bool isLoading = false;

                  if (state is QuestionLoading) {
                    questions = state.currentQuestions;
                    isLoading = true;
                  } else if (state is QuestionLoaded) {
                    questions = state.questions;
                  }

                  if (questions.isEmpty && !isLoading) {
                    return _buildNoQuestionsView();
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < questions.length) {
                          return _buildQuestionCard(questions[index], index);
                        } else if (isLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                      childCount: questions.length + (isLoading ? 1 : 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.secondaryColor],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exam.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.exam.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  _buildInfoRow(Icons.calendar_today,
                      DateFormat('dd MMM yyyy').format(widget.exam.startTime)),
                  SizedBox(height: 4),
                  _buildInfoRow(Icons.access_time,
                      '${DateFormat('HH:mm').format(widget.exam.startTime)} - ${DateFormat('HH:mm').format(widget.exam.endTime)}'),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            _showAddQuestionOptions();
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Q${index + 1}: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor),
                ),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('${question.questionType}'),
            SizedBox(height: 12),
            ..._buildAnswerOptions(question),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 18),
                  label: Text('Edit'),
                  onPressed: () => _editQuestion(question),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryColor),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete, size: 18),
                  label: Text('Delete'),
                  onPressed: () => _deleteQuestion(question),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnswerOptions(Question question) {
    return question.options.map((option) {
      final isCorrect = option == question.correctAnswer;
      return Container(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCorrect ? Colors.green : Colors.grey,
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(option)),
          ],
        ),
      );
    }).toList();
  }

  void _showAddQuestionOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 5,
                width: 40,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Add New Question',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildQuestionTypeCard(
                      icon: Icons.radio_button_checked,
                      title: 'Single Choice Question',
                      description: 'Only one correct answer allowed',
                      onTap: () => _createQuestion('Single Choice'),
                    ),
                    SizedBox(height: 16),
                    _buildQuestionTypeCard(
                      icon: Icons.check_box,
                      title: 'Multiple Choice Question',
                      description: 'Multiple correct answers allowed',
                      onTap: () => _createQuestion('Multiple Choice'),
                    ),
                    SizedBox(height: 16),
                    _buildQuestionTypeCard(
                      icon: Icons.toggle_on,
                      title: 'True/False Question',
                      description: 'Only two options: True or False',
                      onTap: () => _createQuestion('True/False'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionTypeCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppColors.primaryColor),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _createQuestion(String type) {
    Navigator.pop(context);
    if (type == 'Single Choice') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              AddQuestionView(examId: widget.exam.id!, questionType: type),
        ),
      );
    } else if (type == 'Multiple Choice') {
      AlertDialog(
        title: Text('The feature is not available yet'),
        content: Text(''),
      );
    }
  }

  void _editQuestion(Question question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddQuestionView(examId: widget.exam.id!, questionType: question.questionType, question: question),
      ),
    );
  }

  void _deleteQuestion(Question question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          examTitle: widget.exam.title,
          onConfirm: () async {
            await context
                .read<QuestionCubit>()
                .deleteQuestion(widget.exam.id!, question.id!);
            Navigator.of(context).pop(); // Đóng dialog
          },
        );
      },
    );
  }

  Widget _buildNoQuestionsView() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.question_answer_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No questions yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add a new question',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
