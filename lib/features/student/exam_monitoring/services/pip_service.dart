import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

class PipService {
  static const _methodChannel = MethodChannel('com.example.exam_guardian/pip');
  static const _eventChannel = EventChannel('com.example.exam_guardian/pip_events');
  
  final _pipModeController = StreamController<bool>.broadcast();
  StreamSubscription? _eventSubscription;
  bool _isSetup = false;
  
  PipService() {
    print('🔄 Initializing PipService');
    _setupEventChannel();
  }

  void _setupEventChannel() {
    if (!_isPlatformSupported()) {
      print('⚠️ PiP not supported on current platform');
      return;
    }

    if (_isSetup) {
      print('ℹ️ Event channel already setup');
      return;
    }

    try {
      print('🎧 Setting up PiP event channel');
      _eventSubscription?.cancel();
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          print('📱 Received PiP event: $event');
          _pipModeController.add(event as bool);
        },
        onError: (dynamic error) {
          print('❌ PiP event error: $error');
          _pipModeController.addError(error);
        },
        onDone: () {
          print('🏁 PiP event channel closed');
          _isSetup = false;
        },
        cancelOnError: false,
      );
      _isSetup = true;
      print('✅ PiP event listener registered');
    } catch (e) {
      print('❌ Failed to setup PiP event listener: $e');
      _pipModeController.addError(e);
      _isSetup = false;
    }
  }

  void reconnect() {
    print('🔄 Attempting to reconnect PiP service');
    _isSetup = false;
    _setupEventChannel();
  }

  Stream<bool> get pipModeEvents => _pipModeController.stream;

  @override
  void dispose() {
    print('🗑️ Disposing PiP service');
    _eventSubscription?.cancel();
    _pipModeController.close();
    _isSetup = false;
  }

  bool _isPlatformSupported() {
    return Platform.isAndroid || Platform.isIOS;
  }

  Future<bool> isPipSupported() async {
    if (!_isPlatformSupported()) {
      return false;
    }
    
    try {
      final bool result = await _methodChannel.invokeMethod('isPipSupported');
      return result;
    } catch (e) {
      print('❌ Error checking PiP support: $e');
      return false;
    }
  }

  Future<bool> enterPipMode() async {
    try {
      final bool result = await _methodChannel.invokeMethod('enterPipMode');
      return result;
    } catch (e) {
      print('❌ Error entering PiP mode: $e');
      return false;
    }
  }

  Future<bool> isInPipMode() async {
    try {
      final bool result = await _methodChannel.invokeMethod('isInPipMode');
      return result;
    } catch (e) {
      print('❌ Error checking PiP mode: $e');
      return false;
    }
  }
} 