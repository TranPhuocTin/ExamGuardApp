import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../common/models/exam.dart';
import '../cubit/exam_cubit.dart';
import '../../../../configs/app_colors.dart';
import '../cubit/exam_state.dart';

class CreateUpdateExamView extends StatefulWidget {
  final String? filteredStatus;
  final Exam? exam;

  const CreateUpdateExamView({Key? key, this.exam, this.filteredStatus}) : super(key: key);

  @override
  _CreateUpdateExamViewState createState() => _CreateUpdateExamViewState();
}

class _CreateUpdateExamViewState extends State<CreateUpdateExamView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late String _selectedStatus;

  bool get isUpdating => widget.exam != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam?.title ?? '');
    _descriptionController = TextEditingController(text: widget.exam?.description ?? '');
    _startTimeController = TextEditingController(text: widget.exam != null ? _formatDateTime(widget.exam!.startTime) : '');
    _endTimeController = TextEditingController(text: widget.exam != null ? _formatDateTime(widget.exam!.endTime) : '');
    _selectedStatus = widget.filteredStatus ?? widget.exam?.status ?? 'Scheduled';
    
    if (widget.exam != null) {
      _updateExamStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamCubit, ExamState>(
      listener: (context, state) {
        if (state is ExamUpdate && state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${isUpdating ? "Updated" : "Created"} exam successfully')),
          );
          Navigator.of(context).pop(true); // Trả về true để chỉ ra rằng đã cập nhật thành công
        } else if (state is ExamError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to ${isUpdating ? "update" : "create"} exam: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${isUpdating ? "Update" : "Create"} Exam', style: TextStyle(color: Colors.white)),
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
                    child: Text('${isUpdating ? "Update" : "Create"} Exam', style: TextStyle(fontSize: 16)),
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
      onChanged: null, // Disable status change
      validator: (value) => value == null ? 'Please select a status' : null,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final vietnamDateTime = dateTime.add(Duration(hours: 7));
    return DateFormat('yyyy-MM-dd HH:mm').format(vietnamDateTime);
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
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
        
        if (selectedDateTime.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a future date and time')),
          );
          return;
        }

        if (controller == _endTimeController) {
          final startTime = _startTimeController.text.isNotEmpty 
              ? DateFormat('yyyy-MM-dd HH:mm').parse(_startTimeController.text)
              : null;
          if (startTime != null && selectedDateTime.isBefore(startTime)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('End time must be after start time')),
            );
            return;
          }
        }

        final utcDateTime = selectedDateTime.subtract(Duration(hours: 7));
        controller.text = _formatDateTime(utcDateTime);
        _updateExamStatus();
      }
    }
  }

  void _updateExamStatus() {
    final now = DateTime.now();
    final startTime = DateFormat('yyyy-MM-dd HH:mm').parse(_startTimeController.text);
    final endTime = _endTimeController.text.isNotEmpty 
        ? DateFormat('yyyy-MM-dd HH:mm').parse(_endTimeController.text)
        : null;

    setState(() {
      if (startTime.isAfter(now)) {
        _selectedStatus = 'Scheduled';
      } else if (endTime != null && now.isAfter(endTime)) {
        _selectedStatus = 'Completed';
      } else {
        _selectedStatus = 'In Progress';
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return; // Kiểm tra widget còn mounted không

    final startTime = DateFormat('yyyy-MM-dd HH:mm').parse(_startTimeController.text);
    final endTime = DateFormat('yyyy-MM-dd HH:mm').parse(_endTimeController.text);
    final now = DateTime.now();

    if (startTime.isBefore(now)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start time must be in the future')),
      );
      return;
    }

    if (endTime.isBefore(startTime)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final examData = Exam(
      id: isUpdating ? widget.exam!.id : null,
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: startTime,
      endTime: endTime,
      status: _selectedStatus,
    );

    if (isUpdating) {
      await context.read<ExamCubit>().updateExam(examData, widget.exam!.status);
    } else {
      await context.read<ExamCubit>().createExam(examData);
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

