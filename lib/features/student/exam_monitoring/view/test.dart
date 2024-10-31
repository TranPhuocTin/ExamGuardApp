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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaceMonitoringCubit, FaceMonitoringState>(
      builder: (context, state) {
        return Stack(
          children: [
            if (_isCameraInitialized)
              Transform.scale(
                scale: 1.0,
                child: AspectRatio(
                  aspectRatio: _cameraController.value.aspectRatio,
                  child: CameraPreview(_cameraController),
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
      },
    );
  }

  Widget _buildStatusBar(FaceMonitoringState state) {
    final isWarning = state.currentBehavior != CheatingBehavior.normal;

    return Container(
      padding: const EdgeInsets.all(16),
      color: isWarning 
          ? Colors.red.withOpacity(0.9)
          : Colors.green.withOpacity(0.9),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning : Icons.check_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.cheatingLogs.isNotEmpty
                  ? state.cheatingLogs.last.message
                  : 'Đang giám sát...',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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