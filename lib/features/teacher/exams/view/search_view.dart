import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/exam_cubit.dart';
import '../cubit/exam_state.dart';
import '../../../common/widgets/exam_card.dart';
import '../../../../configs/app_colors.dart';
import 'exam_detail_view.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ExamCubit>().loadMoreSearchResults();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
            onPressed: () async {
              if (mounted) {
                Navigator.of(context).pop();
                await context.read<ExamCubit>().loadExams();
              }
            },
          ),
          SizedBox(width: 8),
          Text(
            'Search Exams',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Enter exam name or subject...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<ExamCubit>().searchExams(value);
          }
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<ExamCubit, ExamState>(
      builder: (context, state) {
        if (state is ExamSearchState) {
          if (state.isLoading && state.searchResults.isEmpty) {
            return _buildLoadingIndicator();
          } else if (state.error != null) {
            return _buildErrorMessage(state.error!);
          } else if (state.searchResults.isEmpty) {
            return _buildEmptyResults();
          } else {
            return _buildExamList(state);
          }
        } else {
          return _buildInitialState();
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorMessage(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Text(
        'No exams found',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildExamList(ExamSearchState state) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: state.searchResults.length + 1,
      separatorBuilder: (context, index) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index < state.searchResults.length) {
          return ExamCard(
            exam: state.searchResults[index],
            isShowMoreIcon: true,
            onExamUpdated: () {
              if (mounted) {
                context.read<ExamCubit>().refreshSearchResults();
              }
            },
            onExamTapped: () {
              if (mounted) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExamDetailView(exam: state.searchResults[index])));
              }
            },
          );
        } else if (state.isLoading) {
          return _buildLoadingIndicator();
        } else if (state.hasReachedMax) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No more exams',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Text(
        'Start searching for exams',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
