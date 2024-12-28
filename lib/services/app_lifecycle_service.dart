import 'dart:async';
import 'package:flutter/material.dart';

enum AppState {
  normal,
  background,
  minimized
}

class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  // Stream controllers
  final _appStateController = StreamController<AppState>.broadcast();
  Stream<AppState> get appStateStream => _appStateController.stream;

  // Current state
  AppState _currentState = AppState.normal;
  AppState get currentState => _currentState;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appStateController.close();
  }

  void _updateAppState(AppState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _appStateController.add(newState);
      _handleStateChange(newState);
    }
  }

  void _handleStateChange(AppState state) {
    switch (state) {
      case AppState.background:
        print('Student leaves the exam page while the exam in progress');
        break;
      case AppState.minimized:
        print('Student leaves the exam page while the exam in progress');
        break;
      case AppState.normal:
        print('✅ App returned to normal state');
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _updateAppState(AppState.background);
        break;
      case AppLifecycleState.resumed:
        _updateAppState(AppState.normal);
        break;
      case AppLifecycleState.inactive:
        _updateAppState(AppState.minimized);
        break;
      default:
        break;
    }
  }
}