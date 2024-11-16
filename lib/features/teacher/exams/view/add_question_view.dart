import 'package:flutter/material.dart';
import '../../../../configs/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/models/question_response.dart';
import '../cubit/question_cubit.dart';
import '../cubit/question_state.dart';

class AddQuestionView extends StatefulWidget {
  final String examId;
  final String questionType;
  final Question? question;

  const AddQuestionView({
    Key? key,
    required this.examId,
    required this.questionType,
    this.question,
  }) : super(key: key);

  @override
  _AddQuestionViewState createState() => _AddQuestionViewState();
}

class _AddQuestionViewState extends State<AddQuestionView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late int _correctAnswerIndex;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.question != null) {
      // Editing existing question
      _questionController =
          TextEditingController(text: widget.question!.questionText);
      _optionControllers = widget.question!.options
          .map((option) => TextEditingController(text: option))
          .toList();
      _correctAnswerIndex = widget.question!.correctAnswer != null
          ? widget.question!.options.indexOf(widget.question!.correctAnswer!)
          : 0;
    } else {
      // Creating new question
      _questionController = TextEditingController();
      _optionControllers = [TextEditingController()];
      _correctAnswerIndex = 0;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 1) {
      setState(() {
        _optionControllers.removeAt(index);
        if (_correctAnswerIndex >= _optionControllers.length) {
          _correctAnswerIndex = _optionControllers.length - 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuestionCubit, QuestionState>(
      listener: (context, state) {
        if (state is QuestionCreated || state is QuestionUpdated) {
          String message = state is QuestionCreated
              ? 'Question created successfully'
              : 'Question updated successfully';
          print('AddQuestionView: $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          Navigator.of(context).pop();
        } else if (state is QuestionError) {
          print('AddQuestionView: Error creating question - ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error creating question: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Question', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
          actions: [
            TextButton(
              onPressed: () {
                _submitQuestion();
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: 'Enter your question here',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a question';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ..._buildOptions(),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _addOption,
                  icon: Icon(Icons.add),
                  label: Text('Add Option'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    return List.generate(_optionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          elevation: 2,
          color: _correctAnswerIndex == index ? Colors.greenAccent : null,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Radio<int>(
                  value: index,
                  groupValue: _correctAnswerIndex,
                  onChanged: (value) {
                    setState(() {
                      _correctAnswerIndex = value!;
                    });
                  },
                ),
                Expanded(
                  child: TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      hintText: 'Option ${index + 1}',
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an option';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () => _removeOption(index),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _submitQuestion() {
    print('AddQuestionView: Submitting question');
    if (_formKey.currentState!.validate()) {
      final question = Question(
        id: widget.question?.id, // Include the id if editing
        questionText: _questionController.text,
        options: _optionControllers.map((c) => c.text).toList(),
        correctAnswer: _optionControllers[_correctAnswerIndex].text,
        questionType: widget.questionType,
        questionScore: widget.question?.questionScore ??
            1, // Use existing score or default to 1
      );
      print('AddQuestionView: Created question object');
      print('AddQuestionView: Question details - ${question.toJson()}');
      if (widget.question != null) {
        context.read<QuestionCubit>().updateQuestion(
            widget.examId,
            widget.question!.id!,
            widget.question!.copyWith(
              questionText: _questionController.text,
              options: _optionControllers.map((c) => c.text).toList(),
              correctAnswer: _optionControllers[_correctAnswerIndex].text,
            ));
      } else {
        context.read<QuestionCubit>().createQuestion(widget.examId, question);
      }
    } else {
      print('AddQuestionView: Form validation failed');
    }
  }
}
