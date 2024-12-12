import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../features/student/exam_monitoring/models/cheating_detection_state.dart';
import 'dart:io';


class FaceDetectionService {
  final FaceDetector _faceDetector;
  final double cheatingAngleThreshold;
  final double _minFaceRatio = 0.05;
  final double _maxFaceRatio = 0.65;

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
      return CheatingDetectionState(
        behavior: CheatingBehavior.error,
        message: 'Lỗi xử lý hình ảnh',
        timestamp: DateTime.now(),
      );
    }

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      return CheatingDetectionState(
        behavior: CheatingBehavior.noFaceDetected,
        message: 'Không phát hiện khuôn mặt trong khung hình',
        timestamp: DateTime.now(),
      );
    }

    if (faces.length > 1) {
      return CheatingDetectionState(
        behavior: CheatingBehavior.multipleFaces,
        message: 'Phát hiện nhiều khuôn mặt trong khung hình',
        timestamp: DateTime.now(),
      );
    }

    final face = faces.first;
    final headEulerAngleY = face.headEulerAngleY;

    if (headEulerAngleY != null) {
      if (headEulerAngleY < -cheatingAngleThreshold) {
        return CheatingDetectionState(
          behavior: CheatingBehavior.lookingLeft,
          message: 'Phát hiện quay đầu sang trái',
          timestamp: DateTime.now(),
        );
      } else if (headEulerAngleY > cheatingAngleThreshold) {
        return CheatingDetectionState(
          behavior: CheatingBehavior.lookingRight,
          message: 'Phát hiện quay đầu sang phải',
          timestamp: DateTime.now(),
        );
      }
    }

    final faceSize = face.boundingBox.width * face.boundingBox.height;
    final screenSize = inputImage.metadata!.size.width * inputImage.metadata!.size.height;
    final faceRatio = faceSize / screenSize;

    if (faceRatio < _minFaceRatio || faceRatio > _maxFaceRatio) {
      return CheatingDetectionState(
        behavior: CheatingBehavior.spoofing,
        message: 'Vui lòng điều chỉnh khoảng cách với camera',
        timestamp: DateTime.now(),
      );
    }

    return CheatingDetectionState(
      behavior: CheatingBehavior.normal,
      message: 'Bình thường',
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
      debugPrint('Error disposing face detector: $e');
    }
  }
}