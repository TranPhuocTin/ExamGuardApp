// import 'package:flutter/foundation.dart';
// import 'package:simple_pip_mode/simple_pip.dart';
// import 'package:simple_pip_mode/actions/pip_action.dart';
// import 'dart:async';
// import 'package:flutter/services.dart';
//
// class PIPService {
//   // Singleton instance
//   static final PIPService _instance = PIPService._internal();
//   factory PIPService() => _instance;
//   static const _channel = MethodChannel('simple_pip_mode');
//
//   PIPService._internal() {
//     print('🔧 Initializing PIPService');
//     _simplePip = SimplePip();
//     _setupMethodCallHandler();
//   }
//
//   void _setupMethodCallHandler() {
//     _channel.setMethodCallHandler((call) async {
//       print('📱 Received method call: ${call.method}');
//       switch (call.method) {
//         case 'onPipModeChanged':
//           final bool isInPipMode = call.arguments as bool;
//           print('📱 PiP mode changed (from native): $isInPipMode');
//           _updatePipState(isInPipMode);
//           break;
//       }
//       return null;
//     });
//   }
//
//   void _updatePipState(bool isInPipMode) {
//     if (isInPipMode != _lastPipState) {
//       print('⚡ PIP State Changed!');
//       print('- Previous State: $_lastPipState');
//       print('- Current State: $isInPipMode');
//
//       _lastPipState = isInPipMode;
//       if (isInPipMode) {
//         print('▶️ PIP Mode ACTIVATED');
//         _onPipEntered?.call();
//       } else {
//         print('⏹️ PIP Mode DEACTIVATED');
//         _onPipExited?.call();
//       }
//     }
//   }
//
//   // SimplePip instance
//   late SimplePip _simplePip;
//
//   // Thêm biến để lưu trữ callbacks
//   VoidCallback? _onPipEntered;
//   VoidCallback? _onPipExited;
//
//   // Initialization method
//   void initialize({
//     VoidCallback? onPipEntered,
//     VoidCallback? onPipExited,
//   }) {
//     print('🚀 PIPService: Initializing with callbacks');
//     _onPipEntered = onPipEntered;
//     _onPipExited = onPipExited;
//     _simplePip = SimplePip();
//
//     // Kiểm tra trạng thái ban đầu
//     _checkInitialState();
//
//     // Bắt đầu theo dõi thường xuyên
//     _startPipStateCheck();
//   }
//
//   Future<void> _checkInitialState() async {
//     try {
//       final isInPip = await isCurrentlyInPipMode;
//       print('📱 Initial PIP state: $isInPip');
//       _lastPipState = isInPip;
//     } catch (e) {
//       print('❌ Error checking initial PIP state: $e');
//     }
//   }
//
//   // Thêm phương thức mới để kiểm tra trạng thái PiP
//   Timer? _pipCheckTimer;
//   bool _lastPipState = false;
//
//   void _startPipStateCheck() {
//     _pipCheckTimer?.cancel();
//     print('🔄 Starting PIP state monitoring...');
//
//     _pipCheckTimer =
//         Timer.periodic(const Duration(milliseconds: 100), (timer) async {
//       try {
//         final isInPip = await isCurrentlyInPipMode;
//
//         if (isInPip != _lastPipState) {
//           print('⚡ PIP State Changed!');
//           print('- Previous State: $_lastPipState');
//           print('- Current State: $isInPip');
//
//           _lastPipState = isInPip;
//           if (isInPip) {
//             print('▶️ PIP Mode ACTIVATED');
//             _onPipEntered?.call();
//           } else {
//             print('⏹️ PIP Mode DEACTIVATED');
//             _onPipExited?.call();
//           }
//         }
//       } catch (e) {
//         print('❌ Error in PIP state check: $e');
//         print('Stack trace: $StackTrace.current');
//       }
//     });
//   }
//
//   // Thêm method để kiểm tra trạng thái hiện tại
//   Future<bool> get isCurrentlyInPipMode async {
//     try {
//       if (!await SimplePip.isPipAvailable) {
//         print('❌ PIP not available');
//         return false;
//       }
//
//       final isInPipMode = await _channel.invokeMethod<bool>('isInPictureInPictureMode') ?? false;
//       print('🔍 Current PIP state check: $isInPipMode');
//       return isInPipMode;
//     } catch (e) {
//       print('❌ Error checking current PIP state: $e');
//       print('Stack trace: ${StackTrace.current}');
//       return false;
//     }
//   }
//
//   // Check if PIP is available
//   Future<bool> get isPipAvailable async {
//     try {
//       final isAvailable = await SimplePip.isPipAvailable;
//       print('📱 PIP Available check: $isAvailable');
//       return isAvailable;
//     } catch (e) {
//       print('❌ Error checking PIP availability: $e');
//       return false;
//     }
//   }
//
//   // Check if PIP is currently activated
//   Future<bool> get isPipActivated async {
//     try {
//       final activated = await SimplePip.isPipActivated;
//       print('🔍 Checking PIP Activation: $activated');
//       return activated;
//     } catch (e) {
//       print('❌ Error checking PIP activation: $e');
//       return false;
//     }
//   }
//
//   // Enter PIP Mode
//   Future<void> enterPipMode() async {
//     try {
//       print('🎯 Attempting to enter PIP mode...');
//       if (await isPipAvailable) {
//         await _simplePip.enterPipMode();
//         print('✅ Successfully requested PIP mode');
//       } else {
//         print('⚠️ PIP Mode not available');
//       }
//     } catch (e) {
//       print('❌ Error entering PIP mode: $e');
//       print('Stack trace: $StackTrace.current');
//     }
//   }
//
//   // Set Automatic PIP Mode (requires API 31+)
//   Future<void> setAutoPipMode() async {
//     try {
//       await _simplePip.setAutoPipMode();
//     } catch (e) {
//       debugPrint('Error setting auto PIP mode: $e');
//     }
//   }
//
//   // Handle specific PIP actions
//   void handlePipAction(PipAction action) {
//     switch (action) {
//       case PipAction.play:
//         _onPlay();
//         break;
//       case PipAction.pause:
//         _onPause();
//         break;
//       case PipAction.next:
//         _onNext();
//         break;
//       case PipAction.previous:
//         _onPrevious();
//         break;
//       default:
//         debugPrint('Unhandled PIP action: $action');
//     }
//   }
//
//   // Private methods for handling specific actions
//   void _onPlay() {
//     debugPrint('Play action in PIP mode');
//     // Implement your play logic here
//   }
//
//   void _onPause() {
//     debugPrint('Pause action in PIP mode');
//     // Implement your pause logic here
//   }
//
//   void _onNext() {
//     debugPrint('Next action in PIP mode');
//     // Implement your next item logic here
//   }
//
//   void _onPrevious() {
//     debugPrint('Previous action in PIP mode');
//     // Implement your previous item logic here
//   }
//
//   // Sửa lại phương thức dispose
//   void dispose() {
//     print('🧹 Disposing PIPService');
//     _pipCheckTimer?.cancel();
//     _onPipEntered = null;
//     _onPipExited = null;
//     _simplePip = SimplePip();
//   }
// }
