import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/exam.dart';
import '../../homepage/widgets/exam_card.dart';
import '../data/sample_exams.dart';
import '../widgets/exam_card.dart';
import '../../../../configs/app_colors.dart';

class ExamListPage extends StatefulWidget {
  @override
  _ExamListPageState createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  String _selectedStatus = 'All';
  List<String> _statusOptions = ['All', 'Scheduled', 'In Progress', 'Completed'];
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStatusFilter(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.0),
            sliver: _buildExamList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tạo bài kiểm tra mới
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 180.0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/exam_guard_logo.png',
                        height: 40,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'ExamGuard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Exams',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your exams efficiently',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
        ),
        IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            // Handle notifications
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search exams...',
        prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
        filled: true,
        fillColor: AppColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
      ),
      onChanged: (value) {
        // Implement search functionality
      },
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusOptions.length,
        itemBuilder: (context, index) {
          final status = _statusOptions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status),
              selected: _selectedStatus == status,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = status;
                  });
                }
              },
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              backgroundColor: AppColors.backgroundWhite,
              labelStyle: TextStyle(
                color: _selectedStatus == status ? AppColors.primaryColor : AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamList() {
    final filteredExams = _getFilteredExams();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ExamCard(exam: filteredExams[index]),
          );
        },
        childCount: filteredExams.length,
      ),
    );
  }

  List<Exam> _getFilteredExams() {
    if (_selectedStatus == 'All') {
      return sampleExams;
    } else {
      return sampleExams
          .where((exam) => exam.status?.toLowerCase() == _selectedStatus.toLowerCase())
          .toList();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Advanced Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search by title',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 16),
              Text('Date Range'),
              // Thêm widget chọn khoảng thời gian
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Apply'),
              onPressed: () {
                // Áp dụng bộ lọc
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
