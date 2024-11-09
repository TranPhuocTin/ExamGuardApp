import 'package:equatable/equatable.dart';

abstract class RealtimeState extends Equatable {
  final List<String> messages;
  
  const RealtimeState({this.messages = const []});
  
  @override
  List<Object> get props => [messages];
}

class RealtimeInitial extends RealtimeState {}

class RealtimeConnected extends RealtimeState {
  const RealtimeConnected(List<String> messages) : super(messages: messages);
}

class RealtimeDisconnected extends RealtimeState {
  const RealtimeDisconnected(List<String> messages) : super(messages: messages);
}

class RealtimeError extends RealtimeState {
  final String message;
  
  const RealtimeError(this.message) : super();
  
  @override
  List<Object> get props => [message];
} 