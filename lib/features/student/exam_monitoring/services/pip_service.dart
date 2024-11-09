import 'package:flutter/services.dart';

class PipService {
  static const platform = MethodChannel('com.example.app/pip');
  
  // Check if device supports PiP
  Future<bool> isPipSupported() async {
    try {
      final bool isSupported = await platform.invokeMethod('isPipSupported');
      return isSupported;
    } on PlatformException catch (e) {
      print('Error checking PiP support: ${e.message}');
      return false;
    }
  }

  // Check if app is in PiP mode
  Future<bool> isInPipMode() async {
    try {
      final bool inPipMode = await platform.invokeMethod('isInPipMode');
      return inPipMode;
    } on PlatformException catch (e) {
      print('Error checking PiP mode: ${e.message}');
      return false;
    }
  }

  // Enter PiP mode
  Future<void> enterPipMode() async {
    try {
      await platform.invokeMethod('enterPipMode');
    } on PlatformException catch (e) {
      print('Error entering PiP mode: ${e.message}');
    }
  }
} 