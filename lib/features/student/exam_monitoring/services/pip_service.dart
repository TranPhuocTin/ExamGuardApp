import 'package:flutter/services.dart';

class PipService {
  static const platform = MethodChannel('com.example.app/pip');
  static const eventChannel = EventChannel('com.example.app/pip_events');

  Stream<bool> get pipModeEvents {
    return eventChannel.receiveBroadcastStream().map((event) => event as bool);
  }
} 