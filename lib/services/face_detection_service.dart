import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../features/student/exam_monitoring/models/cheating_detection_state.dart';
import 'dart:io';
import 'monitoring_log_service.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector;
  final double cheatingAngleThreshold;
  final double _minFaceRatio = 0.05;
  final double _maxFaceRatio = 0.65;
  final MonitoringLogService _logService = MonitoringLogService();

  FaceDetectionService({
    this.cheatingAngleThreshold = 25.0,
  }) : _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );

  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Future<CheatingDetectionState> processCameraImage(
      CameraImage image, CameraDescription camera) async {
    final inputImage = await _prepareInputImage(image, camera);
    if (inputImage == null) {
      _logService.logFaceDetection(
        message: 'Error processing camera image',
        details: 'Failed to prepare input image',
      );
      return CheatingDetectionState(
        behavior: CheatingBehavior.error,
        message: 'Error processing camera image',
        timestamp: DateTime.now(),
      );
    }

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      _logService.logFaceNotFound();
      return CheatingDetectionState(
        behavior: CheatingBehavior.noFaceDetected,
        message: 'No face detected in frame',
        timestamp: DateTime.now(),
      );
    }

    if (faces.length > 1) {
      _logService.logMultipleFaces();
      return CheatingDetectionState(
        behavior: CheatingBehavior.multipleFaces,
        message: 'Multiple faces detected in frame',
        timestamp: DateTime.now(),
      );
    }

    final face = faces.first;
    final headEulerAngleY = face.headEulerAngleY;

    if (headEulerAngleY != null) {
      if (headEulerAngleY < -cheatingAngleThreshold) {
        _logService.logFacePosition('Looking left');
        return CheatingDetectionState(
          behavior: CheatingBehavior.lookingRight,
          message: 'Head turned to the right',
          timestamp: DateTime.now(),
        );
      } else if (headEulerAngleY > cheatingAngleThreshold) {
        _logService.logFacePosition('Looking right');
        return CheatingDetectionState(
          behavior: CheatingBehavior.lookingLeft,
          message: 'Head turned to the left',
          timestamp: DateTime.now(),
        );
      }
    }

    final faceSize = face.boundingBox.width * face.boundingBox.height;
    final screenSize = inputImage.metadata!.size.width * inputImage.metadata!.size.height;
    final faceRatio = faceSize / screenSize;

    if (faceRatio < _minFaceRatio || faceRatio > _maxFaceRatio) {
      _logService.logFaceDetection(
        message: 'Invalid face distance',
        details: 'Face too ${faceRatio < _minFaceRatio ? "far" : "close"} from camera',
      );
      return CheatingDetectionState(
        behavior: CheatingBehavior.spoofing,
        message: 'Please adjust your distance from the camera',
        timestamp: DateTime.now(),
      );
    }

    _logService.logFaceDetected();
    return CheatingDetectionState(
      behavior: CheatingBehavior.normal,
      message: 'Normal',
      timestamp: DateTime.now(),
    );
  }

  Future<InputImage?> _prepareInputImage(CameraImage image, CameraDescription camera) async {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotation.values.firstWhere(
            (element) => element.rawValue == sensorOrientation,
      );
    } else if (Platform.isAndroid) {
      final rotationCompensation = _orientations[DeviceOrientation.portraitUp]!;

      if (camera.lensDirection == CameraLensDirection.front) {
        rotation = InputImageRotation.values.firstWhere(
              (element) => element.rawValue == ((sensorOrientation + rotationCompensation) % 360),
        );
      } else {
        rotation = InputImageRotation.values.firstWhere(
              (element) => element.rawValue == ((sensorOrientation - rotationCompensation + 360) % 360),
        );
      }
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void dispose() {
    try {
      _faceDetector.close();
    } catch (e) {
      _logService.logFaceDetection(
        message: 'Error disposing face detector',
        details: e.toString(),
      );
    }
  }
}