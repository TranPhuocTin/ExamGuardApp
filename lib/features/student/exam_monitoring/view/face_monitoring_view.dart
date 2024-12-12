import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/face_monitoring_cubit.dart';
import '../cubit/face_monitoring_state.dart';
import '../../../../services/face_detection_service.dart';
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
  
  // Thay đổi giá trị mặc định của _isMinimized thành true
  bool _isMinimized = true;
  double _xPosition = 0.0;
  double _yPosition = 0.0;
  
  // Kích thước cho normal và minimized mode
  static const double _normalWidth = 320.0;
  static const double _normalHeight = 240.0;
  static const double _minimizedWidth = 160.0;
  static const double _minimizedHeight = 120.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setDefaultPosition();
    });
    print('📱 Khởi tạo Face Monitoring View');
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
      // Chỉ cập nhật vị trí, không thay đổi _isMinimized
      _xPosition = screenSize.width - (_isMinimized ? _minimizedWidth : _normalWidth) - 16;
      _yPosition = 16.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentWidth = _isMinimized ? _minimizedWidth : _normalWidth;
    final currentHeight = _isMinimized ? _minimizedHeight : _normalHeight;

    return BlocBuilder<FaceMonitoringCubit, FaceMonitoringState>(
      builder: (context, state) {
        return Positioned(
          left: _xPosition.clamp(0, screenSize.width - currentWidth),
          top: _yPosition.clamp(0, screenSize.height - currentHeight),
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
      padding: EdgeInsets.symmetric(
        horizontal: _isMinimized ? 2 : 8,
        vertical: _isMinimized ? 1 : 4,
      ),
      height: _isMinimized ? 16 : 28,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isMinimized ? '' : 'Camera Monitor',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: _isMinimized ? 16 : 24,
              minHeight: _isMinimized ? 16 : 24,
            ),
            icon: Icon(
              _isMinimized ? Icons.open_in_full : Icons.close_fullscreen,
              color: Colors.white,
              size: _isMinimized ? 12 : 16,
            ),
            onPressed: () {
              setState(() {
                _isMinimized = !_isMinimized;
                // Cập nhật vị trí sau khi thay đổi trạng thái
                _setDefaultPosition();
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
        vertical: _isMinimized ? 2 : 4,
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
            size: _isMinimized ? 12 : 14,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              state.cheatingLogs.isNotEmpty
                  ? state.cheatingLogs.last.message
                  : 'Đang giám sát...',
              style: TextStyle(
                color: Colors.white,
                fontSize: _isMinimized ? 10 : 12,
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
      // Dừng camera stream trước
      if (_cameraController.value.isStreamingImages) {
        await _cameraController.stopImageStream();
      }
      
      // Thêm delay ngắn để đảm bảo stream đã dừng hoàn toàn
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Kiểm tra xem camera có được khởi tạo không trước khi dispose
      if (_isCameraInitialized && _cameraController.value.isInitialized) {
        await _cameraController.dispose();
      }
      
      // Dispose face detection service
      _faceDetectionService.dispose();
    } catch (e) {
      debugPrint('Error disposing camera resources: $e');
    } finally {
      _isCameraInitialized = false;
    }
  }
} 