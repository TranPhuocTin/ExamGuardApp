
import 'package:exam_guardian/features/realtime/cubit/realtime_cubit.dart';

class RealtimeMessageReceived extends RealtimeState {
  final String event;
  final dynamic data;
  
  RealtimeMessageReceived({
    required this.event,
    required this.data,
    required List<String> messages,
  }) : super(messages: messages);
} 