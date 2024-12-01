import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/app_colors.dart';
import '../../../../utils/mixins/infinite_scroll_mixin.dart';
import '../cubit/cheating_history_cubit.dart';
import '../cubit/cheating_history_state.dart';
import '../model/cheating_history_response.dart';
import 'package:intl/intl.dart';

import '../model/cheating_statistics_response.dart';

class CheatingHistoryDialog extends StatefulWidget {
  final String examId;
  final String studentId;
  final String studentName;
  final CheatingStatistic stat;

  const CheatingHistoryDialog({
    Key? key,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.stat,
  }) : super(key: key);

  @override
  State<CheatingHistoryDialog> createState() => _CheatingHistoryDialogState();
}

class _CheatingHistoryDialogState extends State<CheatingHistoryDialog> with InfiniteScrollMixin {
  bool _isDialogActive = true;
  late final CheatingHistoryCubit _cheatingHistoryCubit;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _cheatingHistoryCubit = context.read<CheatingHistoryCubit>();
  }

  @override
  void dispose() {
    _isDialogActive = false;
    super.dispose();
  }

  void _loadMore(BuildContext context) {
    if (!mounted || !_isDialogActive) return;
    _cheatingHistoryCubit.loadHistories(widget.examId, widget.studentId);
  }

  @override
  void onLoadMore() {
    if (!mounted || !_isDialogActive) return;
    final state = _cheatingHistoryCubit.state;
    if (state is CheatingHistoryLoaded && !state.hasReachedMax) {
      _loadMore(context);
    }
  }

  void _filterByType(String? type) {
    if (!mounted) return;
    setState(() {
      _selectedFilter = type;
    });
    _cheatingHistoryCubit.filterHistories(type);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildStatistics(),
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Violation Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                          child: Text(
                            widget.studentName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.studentName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.textSecondary),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final faceViolations = widget.stat.faceDetectionCount;
    final tabViolations = widget.stat.tabSwitchCount;
    final screenViolations = widget.stat.screenCaptureCount;
    final totalViolations = faceViolations + tabViolations + screenViolations;
    
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<CheatingHistoryCubit, CheatingHistoryState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  child: _buildStatCard(
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                    count: totalViolations,
                    label: 'All',
                    onTap: () => _filterByType(null),
                    isSelected: _selectedFilter == null,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: _buildStatCard(
                    icon: Icons.face,
                    color: Colors.red,
                    count: faceViolations,
                    label: 'Face',
                    onTap: () => _filterByType('Face'),
                    isSelected: _selectedFilter == 'Face',
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: _buildStatCard(
                    icon: Icons.tab,
                    color: Colors.orange,
                    count: tabViolations,
                    label: 'Tab Switch',
                    onTap: () => _filterByType('Switch Tab'),
                    isSelected: _selectedFilter == 'Switch Tab',
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: _buildStatCard(
                    icon: Icons.screenshot,
                    color: Colors.purple,
                    count: screenViolations,
                    label: 'Screen',
                    onTap: () => _filterByType('Screen Capture'),
                    isSelected: _selectedFilter == 'Screen Capture',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return BlocBuilder<CheatingHistoryCubit, CheatingHistoryState>(
      builder: (context, state) {
        if (state is CheatingHistoryLoading) {
          return _buildLoadingState();
        } else if (state is CheatingHistoryError) {
          return _buildErrorState(state.message);
        } else if (state is CheatingHistoryLoaded) {
          if (state.histories.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              await _cheatingHistoryCubit.refreshHistories(
                widget.examId,
                widget.studentId,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: state.histories.length + 1,
              itemBuilder: (context, index) {
                if (index < state.histories.length) {
                  return _buildHistoryItem(state.histories[index]);
                } else if (!state.hasReachedMax) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              controller: scrollController,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHistoryItem(CheatingHistory history) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _getInfractionIcon(history.infractionType),
        title: Text(
          history.description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm:ss').format(history.timeDetected ?? DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getInfractionIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'Face':
        iconData = Icons.face;
        iconColor = Colors.red;
        break;
      case 'Switch_Tab':
        iconData = Icons.tab;
        iconColor = Colors.orange;
        break;
      case 'Screen Capture':
        iconData = Icons.screenshot;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.warning;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
    required Function() onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(message),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No violations found'),
    );
  }
} 