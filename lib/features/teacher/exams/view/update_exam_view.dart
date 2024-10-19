import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/exam.dart';
import '../cubit/exam_cubit.dart';
import '../../../../configs/app_colors.dart';
import '../cubit/exam_state.dart';

class UpdateExamView extends StatefulWidget {
  final Exam exam;

  const UpdateExamView({Key? key, required this.exam}) : super(key: key);

  @override
  _UpdateExamViewState createState() => _UpdateExamViewState();
}

class _UpdateExamViewState extends State<UpdateExamView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam.title);
    _descriptionController = TextEditingController(text: widget.exam.description);
    _startTimeController = TextEditingController(text: _formatDateTime(widget.exam.startTime));
    _endTimeController = TextEditingController(text: _formatDateTime(widget.exam.endTime));
    _selectedStatus = widget.exam.status;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamCubit, ExamState>(
      listener: (context, state) {
        if (state is ExamUpdate && state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exam updated successfully')),
          );
          Navigator.of(context).pop(); // Pop immediately after successful update
        } else if (state is ExamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update exam: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Exam', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                SizedBox(height: 24),
                _buildTextField(
                  controller: _titleController,
                  label: 'Title',
                  icon: Icons.title,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                _buildDateTimeField(
                  controller: _startTimeController,
                  label: 'Start Time',
                  icon: Icons.access_time,
                  onTap: () => _selectDateTime(context, _startTimeController),
                ),
                SizedBox(height: 16),
                _buildDateTimeField(
                  controller: _endTimeController,
                  label: 'End Time',
                  icon: Icons.access_time,
                  onTap: () => _selectDateTime(context, _endTimeController),
                ),
                SizedBox(height: 16),
                _buildStatusDropdown(),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Update Exam', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.flag, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['In Progress', 'Scheduled', 'Completed'].map((String status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedStatus = newValue!;
        });
      },
      validator: (value) => value == null ? 'Please select a status' : null,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
        controller.text = _formatDateTime(selectedDateTime);
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedExam = widget.exam.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: DateFormat('yyyy-MM-dd HH:mm').parse(_startTimeController.text),
        endTime: DateFormat('yyyy-MM-dd HH:mm').parse(_endTimeController.text),
        status: _selectedStatus,
      );
      await context.read<ExamCubit>().updateExam(updatedExam, widget.exam.status);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}
