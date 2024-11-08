import 'package:dio/dio.dart';
import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/student/exam_monitoring/models/detect_cheating.dart';
import 'package:exam_guardian/features/student/exam_monitoring/models/cheating_detection_state.dart';

import '../configs/dio_config.dart';

class CheatingRepository {
  Future<void> submitDetectCheating(
    String clientId, 
    String token, 
    String examId,
    CheatingDetectionState detectionState
  ) async {
    final detectCheating = DetectCheating(
      infractionType: _mapBehaviorToInfractionType(detectionState.behavior),
      description: detectionState.message,
    );
    
    final data = {
      ...detectCheating.toJson(),
    };

    await DioClient.performRequest(
      ApiUrls.reportCheating(examId),
      clientId: clientId,
      token: token,
      method: 'POST',
      data: data,
    );
  }

  InfractionType _mapBehaviorToInfractionType(CheatingBehavior behavior) {
    switch (behavior) {
      case CheatingBehavior.lookingLeft:
      case CheatingBehavior.lookingRight:
        return InfractionType.face;
      case CheatingBehavior.multipleFaces:
        return InfractionType.face;
      case CheatingBehavior.noFaceDetected:
        return InfractionType.face;
      case CheatingBehavior.eyesClosed:
        return InfractionType.face;
      case CheatingBehavior.spoofing:
        return InfractionType.face;
      default:
        return InfractionType.face;
    }
  }
}