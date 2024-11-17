import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/mixins/infinite_scroll_mixin.dart';
import '../cubit/cheating_history_cubit.dart';
import '../cubit/cheating_history_state.dart';
import '../model/cheating_history_response.dart';
import 'package:intl/intl.dart';

class CheatingHistoryDialog extends StatefulWidget {
  final String examId;
  final String studentId;
  final String studentName;

  const CheatingHistoryDialog({
    Key? key,
    required this.examId,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<CheatingHistoryDialog> createState() => _CheatingHistoryDialogState();
}

class _CheatingHistoryDialogState extends State<CheatingHistoryDialog> with InfiniteScrollMixin {
  bool _isDialogActive = true;
  late final CheatingHistoryCubit _cheatingHistoryCubit;

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _isDialogActive = false;
        return true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(),
              Expanded(
                child: _buildHistoryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chi tiết vi phạm',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                widget.studentName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return BlocBuilder<CheatingHistoryCubit, CheatingHistoryState>(
      builder: (context, state) {
        if (state is CheatingHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CheatingHistoryError) {
          return Center(child: Text(state.message));
        } else if (state is CheatingHistoryLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              await _cheatingHistoryCubit
                .refreshHistories(widget.examId, widget.studentId);
            },
            child: ListView.builder(
              itemCount: state.histories.length + 1,
              itemBuilder: (context, index) {
                if (index < state.histories.length) {
                  return _buildHistoryItem(state.histories[index]);
                } else if (!state.hasReachedMax) {
                  _loadMore(context);
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return const SizedBox();
                }
              },
              controller: scrollController,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildHistoryItem(CheatingHistory history) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _getInfractionIcon(history.infractionType),
        title: Text(history.description),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm:ss').format(history.createdAt),
          style: const TextStyle(fontSize: 12),
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
} 