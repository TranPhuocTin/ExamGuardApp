import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/socket_service.dart';
import '../../../realtime/cubit/realtime_cubit.dart';
import 'package:exam_guardian/features/common/models/exam.dart' as common;
import '../cubit/cheating_statistics_cubit.dart';
import '../../../../utils/share_preference/shared_preference.dart';
import '../../../../data/cheating_repository.dart';
import '../cubit/cheating_statistics_state.dart';
import '../model/cheating_statistics_response.dart';

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
          )..loadStatistics(exam.id!),
        ),
        BlocProvider(
          create: (context) => RealtimeCubit(
            context.read<TokenStorage>(),
            context.read<SocketService>(),
            onEventReceived: (event, data) {
              if (event == 'newCheatingDetected') {
                print('📊 Gửi dữ liệu đến CheatingStatisticsCubit');
                context
                  .read<CheatingStatisticsCubit>()
                  .handleNewCheatingDetected(data['data']);
              }
            },
          )..initializeSocket(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Monitoring: ${exam.title}'),
        ),
        body: _StatisticsTab(exam: exam),
      ),
    );
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
            BlocBuilder<RealtimeCubit, RealtimeState>(
              builder: (context, realtimeState) {
                return _buildConnectionStatus(realtimeState);
              },
            ),
            const Divider(),
            if (state is CheatingStatisticsLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is CheatingStatisticsError)
              Expanded(
                child: Center(child: Text(state.message)),
              )
            else if (state is CheatingStatisticsLoaded)
              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(context),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await context.read<CheatingStatisticsCubit>().refreshStatistics(exam.id!);
                        },
                        child: ListView.builder(
                          itemCount: state.statistics.length,
                          itemBuilder: (context, index) {
                            final stat = state.statistics[index];
                            return _buildStatisticsCard(stat);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildConnectionStatus(RealtimeState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: _getStatusColor(state),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(state),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusMessage(state),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
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

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by student name or email',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (query) {
          context.read<CheatingStatisticsCubit>().filterStatistics(query);
        },
      ),
    );
  }

  Widget _buildStatisticsCard(CheatingStatistic stat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(stat.student.avatar),
                  radius: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.student.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stat.student.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatisticRow(
              Icons.face, 
              'Face Detection Violations',
              stat.faceDetectionCount,
            ),
            _buildStatisticRow(
              Icons.tab, 
              'Tab Switch Violations',
              stat.tabSwitchCount,
            ),
            _buildStatisticRow(
              Icons.screenshot, 
              'Screen Capture Violations',
              stat.screenCaptureCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: count > 0 ? Colors.red[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: count > 0 ? Colors.red[700] : Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 