import 'package:exam_guardian/configs/app_colors.dart';
import 'package:exam_guardian/utils/share_preference/token_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/socket_service.dart';
import '../../../realtime/cubit/realtime_cubit.dart';
import 'package:exam_guardian/features/common/models/exam.dart' as common;
import '../cubit/cheating_history_cubit.dart';
import '../cubit/cheating_statistics_cubit.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../data/cheating_repository.dart';
import '../cubit/cheating_statistics_state.dart';
import '../cubit/exam_cubit.dart';
import '../model/cheating_statistics_response.dart';
import 'cheating_history_dialog.dart';

class TeacherExamMonitoringView extends StatelessWidget {
  final common.Exam exam;

  const TeacherExamMonitoringView({
    Key? key,
    required this.exam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CheatingStatisticsCubit(
            context.read<CheatingRepository>(),
            context.read<TokenStorage>(),
            context.read<TokenCubit>()
          )..loadStatistics(exam.id!),
        ),
        BlocProvider(
          create: (context) => RealtimeCubit(
            context.read<TokenStorage>(),
            context.read<SocketService>(),
            onEventReceived: (event, data) {
              if (event == 'newCheatingDetected' && data != null) {
                if (data['data'] is Map<String, dynamic>) {
                  context
                    .read<CheatingStatisticsCubit>()
                    .handleNewCheatingDetected(data['data']);
                }
              } else if (event == 'examUpdated' && data != null) {
                if (data['exam'] is Map<String, dynamic>) {
                  final updatedExam = common.Exam.fromJson(data['exam']);
                  context.read<ExamCubit>().handleExamUpdated(updatedExam);
                }
              }
            },
          )..initializeSocket(),
        ),
      ],
      child: Scaffold(
        extendBody: false,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildCustomAppBar(context),
        ),
        body: _StatisticsTab(exam: exam),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return BlocBuilder<RealtimeCubit, RealtimeState>(
      builder: (context, state) {
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
                          exam.title,
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
                          'Monitoring',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Connection Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(state).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(state),
                          size: 14,
                          color: _getStatusColor(state),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusMessage(state),
                          style: TextStyle(
                            color: _getStatusColor(state),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
      },
    );
  }

  Color _getStatusColor(RealtimeState state) {
    if (state is RealtimeConnected) return Colors.green;
    if (state is RealtimeDisconnected) return Colors.red;
    if (state is RealtimeError) return Colors.orange;
    return Colors.grey;
  }

  IconData _getStatusIcon(RealtimeState state) {
    if (state is RealtimeConnected) return Icons.check_circle;
    if (state is RealtimeDisconnected) return Icons.error_outline;
    if (state is RealtimeError) return Icons.warning;
    return Icons.hourglass_empty;
  }

  String _getStatusMessage(RealtimeState state) {
    if (state is RealtimeConnected) return 'Connected';
    if (state is RealtimeDisconnected) return 'Disconnected';
    if (state is RealtimeError) return 'Error: ${state.message}';
    return 'Initializing...';
  }
}

class _StatisticsTab extends StatelessWidget {
  final common.Exam exam;

  const _StatisticsTab({required this.exam});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheatingStatisticsCubit, CheatingStatisticsState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.05),
                      Colors.white,
                    ],
                  ),
                ),
                child: _buildContent(context, state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, CheatingStatisticsState state) {
    if (state is CheatingStatisticsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CheatingStatisticsError) {
      return Center(child: Text(state.message));
    } else if (state is CheatingStatisticsLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<CheatingStatisticsCubit>().refreshStatistics(exam.id!);
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.statistics.length,
          itemBuilder: (context, index) => _buildStudentCard(context, state.statistics[index]),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStudentCard(BuildContext context, CheatingStatistic stat) {
    final totalViolations = stat.faceDetectionCount + stat.tabSwitchCount + stat.screenCaptureCount;
    final hasViolations = totalViolations > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showHistoryDialog(context, stat),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasViolations ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildStudentHeader(stat, hasViolations),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildViolationIndicator(
                      'Face Detection',
                      stat.faceDetectionCount,
                      Icons.face,
                    ),
                    const SizedBox(height: 8),
                    _buildViolationIndicator(
                      'Tab Switch',
                      stat.tabSwitchCount,
                      Icons.tab,
                    ),
                    const SizedBox(height: 8),
                    _buildViolationIndicator(
                      'Screen Capture',
                      stat.screenCaptureCount,
                      Icons.screenshot,
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

  Widget _buildStudentHeader(CheatingStatistic stat, bool hasViolations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasViolations ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: hasViolations ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: hasViolations ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.student.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: hasViolations ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasViolations ? Icons.warning : Icons.check_circle,
                  size: 16,
                  color: hasViolations ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  hasViolations ? 'Violations Detected' : 'No Violations',
                  style: TextStyle(
                    color: hasViolations ? Colors.red : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationIndicator(String label, int count, IconData icon) {
    final hasViolation = count > 0;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasViolation ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: hasViolation ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: hasViolation ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: hasViolation ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showHistoryDialog(BuildContext context, CheatingStatistic stat) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => CheatingHistoryCubit(
          context.read<CheatingRepository>(),
          context.read<TokenStorage>(),
          context.read<TokenCubit>()
        )..loadHistories(exam.id!, stat.student.id),
        child: CheatingHistoryDialog(
          examId: exam.id!,
          studentId: stat.student.id,
          studentName: stat.student.name,
          stat: stat,
        ),
      ),
    );
  }
} 