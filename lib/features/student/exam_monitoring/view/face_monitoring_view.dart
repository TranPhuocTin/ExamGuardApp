import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/face_monitoring_cubit.dart';
import '../services/face_detection_service.dart';
import '../models/cheating_detection_state.dart';

class FaceMonitoringView extends StatefulWidget {
  final String examId;

  const FaceMonitoringView({
    Key? key,
    required this.examId,
  }) : super(key: key);

  @override
  State<FaceMonitoringView> createState() => _FaceMonitoringViewState();
}

class _FaceMonitoringViewState extends State<FaceMonitoringView> {
  late CameraController _cameraController;
  late FaceDetectionService _faceDetectionService;
  bool _isCameraInitialized = false;
  
  // Thêm các biến quản lý PiP mode
  bool _isPipMode = false;
  double _xPosition = 0.0;
  double _yPosition = 0.0;
  
  // Kích thước cho normal mode và pip mode
  static const double _normalWidth = 320.0;
  static const double _normalHeight = 240.0;
  static const double _pipWidth = 160.0;
  static const double _pipHeight = 120.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setDefaultPosition();
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _faceDetectionService = FaceDetectionService();
      _startMonitoring();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      context.read<FaceMonitoringCubit>().handleError(e.toString());
    }
  }

  void _startMonitoring() {
    _cameraController.startImageStream((image) async {
      try {
        final detectionState = await _faceDetectionService.processCameraImage(
          image,
          _cameraController.description,
        );
        if (mounted) {
          context.read<FaceMonitoringCubit>().updateCheatingState(detectionState);
        }
      } catch (e) {
        print('Error processing image: $e');
      }
    });
  }

  void _setDefaultPosition() {
    final screenSize = MediaQuery.of(context).size;
    setState(() {
      if (_isPipMode) {
        // PiP mode: góc trên bên phải
        _xPosition = screenSize.width - _pipWidth - 20;
        _yPosition = 20.0;
      } else {
        // Normal mode: giữa trên cùng
        _xPosition = (screenSize.width - _normalWidth) / 2;
        _yPosition = 20.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentWidth = _isPipMode ? _pipWidth : _normalWidth;
    final currentHeight = _isPipMode ? _pipHeight : _normalHeight;

    return BlocBuilder<FaceMonitoringCubit, FaceMonitoringState>(
      builder: (context, state) {
        return Positioned(
          left: _xPosition,
          top: _yPosition,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _xPosition += details.delta.dx;
                _yPosition += details.delta.dy;
                
                // Giới hạn không cho widget ra khỏi màn hình
                _xPosition = _xPosition.clamp(
                  0.0,
                  screenSize.width - currentWidth,
                );
                _yPosition = _yPosition.clamp(
                  0.0,
                  screenSize.height - currentHeight,
                );
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: currentWidth,
              height: currentHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildControlBar(),
                  Expanded(child: _buildMonitoringContent(state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isPipMode ? '' : 'Camera Monitor',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              _isPipMode ? Icons.open_in_full : Icons.close_fullscreen,
              color: Colors.white,
              size: 16,
            ),
            onPressed: () {
              setState(() {
                _isPipMode = !_isPipMode;
                _setDefaultPosition(); // Reset về vị trí mặc định khi chuyển mode
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringContent(FaceMonitoringState state) {
    return Stack(
      children: [
        if (_isCameraInitialized)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
            child: Transform.scale(
              scale: 1.0,
              child: AspectRatio(
                aspectRatio: _cameraController.value.aspectRatio,
                child: CameraPreview(_cameraController),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildStatusBar(state),
        ),
      ],
    );
  }

  Widget _buildStatusBar(FaceMonitoringState state) {
    final isWarning = state.currentBehavior != CheatingBehavior.normal;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: _isPipMode ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.withOpacity(0.9)
            : Colors.green.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning : Icons.check_circle,
            color: Colors.white,
            size: _isPipMode ? 12 : 14,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              state.cheatingLogs.isNotEmpty
                  ? state.cheatingLogs.last.message
                  : 'Đang giám sát...',
              style: TextStyle(
                color: Colors.white,
                fontSize: _isPipMode ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposeResources();
    super.dispose();
  }

  Future<void> _disposeResources() async {
    try {
      if (_cameraController.value.isStreamingImages) {
        await _cameraController.stopImageStream();
      }
      await Future.delayed(const Duration(milliseconds: 300));

      if (_isCameraInitialized) {
        await _cameraController.dispose();
      }

      _faceDetectionService.dispose();
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }
  }
} 