import 'package:flutter/material.dart';

class WindowPipService with WidgetsBindingObserver {
  // Callback functions
  final Function(bool) onPipModeChanged;
  bool _isInPipMode = false;

  WindowPipService({required this.onPipModeChanged}) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _checkPipStateOnMetricsChange();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.resumed) {
      _checkPipStateOnMetricsChange();
    }
  }

  void _checkPipStateOnMetricsChange() {
    final window = WidgetsBinding.instance.window;
    final size = window.physicalSize;
    final ratio = window.devicePixelRatio;
    
    final actualWidth = size.width / ratio;
    final actualHeight = size.height / ratio;
    
    final isSmallWindow = actualWidth < 500 || actualHeight < 500;
    
    if (isSmallWindow != _isInPipMode) {
      _isInPipMode = isSmallWindow;
      onPipModeChanged(_isInPipMode);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
} 