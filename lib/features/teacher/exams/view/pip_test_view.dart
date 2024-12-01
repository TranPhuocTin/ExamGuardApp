// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:simple_pip_mode/pip_widget.dart';
//
// import '../../../student/exam_monitoring/services/pip_service.dart';
//
// class PiPTestView extends StatefulWidget {
//   const PiPTestView({super.key});
//
//   @override
//   State<PiPTestView> createState() => _PiPTestViewState();
// }
//
// class _PiPTestViewState extends State<PiPTestView> with WidgetsBindingObserver {
//   bool _isPipAvailable = false;
//   bool _isInPipMode = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     print('🚀 Initializing PiPTestView');
//     _checkPipAvailability();
//     _initializePip();
//   }
//
//   @override
//   void didChangeMetrics() {
//     super.didChangeMetrics();
//     print('📐 Window metrics changed');
//
//     // Đợi một chút để window metrics ổn định
//     Future.delayed(const Duration(milliseconds: 100), () {
//       _checkPipStateOnMetricsChange();
//     });
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     print('🔄 App lifecycle changed: $state');
//
//     // Check khi app chuyển sang inactive (có thể là do vào PiP)
//     if (state == AppLifecycleState.inactive) {
//       _checkPipStateOnStateChange();
//     }
//     // Check khi app resumed (có thể là do thoát PiP)
//     else if (state == AppLifecycleState.resumed) {
//       _checkPipStateOnStateChange();
//     }
//   }
//
//   Future<void> _checkPipStateOnStateChange() async {
//     if (!mounted) return;
//
//     // Đợi một chút để system hoàn thành transition
//     await Future.delayed(const Duration(milliseconds: 100));
//
//     final isInPip = await _pipService.isCurrentlyInPipMode;
//     print('🔍 PiP check on state change: $isInPip');
//
//     if (isInPip != _isInPipMode) {
//       setState(() {
//         _isInPipMode = isInPip;
//         print('🔄 Updated UI state on state change - PiP Mode: $_isInPipMode');
//       });
//     }
//   }
//
//   Future<void> _checkPipStateOnMetricsChange() async {
//     if (!mounted) return;
//
//     final window = WidgetsBinding.instance.window;
//     final size = window.physicalSize;
//     final insetBottom = window.viewInsets.bottom;
//
//     print('📊 Window Metrics:');
//     print('- Size: $size');
//     print('- Inset Bottom: $insetBottom');
//     print('- Pixel Ratio: ${window.devicePixelRatio}');
//
//     // Check if size indicates PiP mode (usually much smaller)
//     final isSmallWindow = size.width < 1000 || size.height < 1000;
//     print('- Is Small Window: $isSmallWindow');
//
//     final isInPip = await _pipService.isCurrentlyInPipMode;
//     print('🔍 PiP check on metrics change: $isInPip');
//
//     if (isInPip != _isInPipMode) {
//       setState(() {
//         _isInPipMode = isInPip;
//         print(
//             '🔄 Updated UI state on metrics change - PiP Mode: $_isInPipMode');
//       });
//     }
//   }
//
//   Future<void> _checkPipAvailability() async {
//     print('🔍 Checking PiP availability...');
//     final isAvailable = await _pipService.isPipAvailable;
//     print('📱 PiP Available: $isAvailable');
//     setState(() {
//       _isPipAvailable = isAvailable;
//     });
//   }
//
//   void _initializePip() {
//     print('🔧 Initializing PiP callbacks...');
//     _pipService.initialize(
//       onPipEntered: () {
//         print('📱 View received PiP ENTER notification');
//         if (mounted) {
//           setState(() {
//             _isInPipMode = true;
//             print('🔄 Updated UI - PiP Mode: $_isInPipMode');
//           });
//         }
//       },
//       onPipExited: () {
//         print('📱 View received PiP EXIT notification');
//         if (mounted) {
//           setState(() {
//             _isInPipMode = false;
//             print('🔄 Updated UI - PiP Mode: $_isInPipMode');
//           });
//         }
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: PipWidget(
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('PiP Test'),
//             actions: [
//               if (_isPipAvailable)
//                 IconButton(
//                   onPressed: _pipService.enterPipMode,
//                   icon: const Icon(Icons.picture_in_picture),
//                 ),
//             ],
//           ),
//           body: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'PiP Available: ${_isPipAvailable ? 'Yes' : 'No'}',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Current Mode: ${_isInPipMode ? 'PiP Active' : 'Normal'}',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//                 const SizedBox(height: 20),
//                 if (_isPipAvailable)
//                   ElevatedButton(
//                     onPressed: _pipService.enterPipMode,
//                     child: const Text('Enter PiP Mode'),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         pipChild: _buildPipModeContent(),
//       ),
//     );
//   }
//
//   Widget _buildPipModeContent() {
//     return Container(
//       color: Colors.black,
//       child: const Center(
//         child: Text(
//           'PiP Mode Active',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     print('🧹 Disposing PiPTestView');
//     WidgetsBinding.instance.removeObserver(this);
//     _pipService.dispose();
//     super.dispose();
//   }
// }
