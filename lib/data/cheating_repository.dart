import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/features/student/exam_monitoring/models/detect_cheating.dart';
import 'package:exam_guardian/features/student/exam_monitoring/models/cheating_detection_state.dart';

import '../configs/dio_client.dart';
import '../features/teacher/exams/model/cheating_statistics_response.dart';
import '../features/teacher/exams/model/cheating_history_response.dart';

class CheatingRepository {
  Future<void> submitDetectCheating(String clientId, String token,
      String examId, CheatingDetectionState detectionState) async {
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

  Future<CheatingStatisticsResponse> getCheatingStatistics(
    String clientId,
    String token,
    String examId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await DioClient.performRequest(
      ApiUrls.getcheatingStatistics(examId),
      clientId: clientId,
      token: token,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return CheatingStatisticsResponse.fromJson(response.data);
  }

  Future<CheatingHistoryResponse> getCheatingHistories(
    String clientId,
    String token,
    String examId,
    String studentId, {
    int page = 1,
    int limit = 5,
    String? infractionType,
  }) async {
    final response = await DioClient.performRequest(
      ApiUrls.getCheatingHistories(examId, studentId),
      clientId: clientId,
      token: token,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (infractionType != null) 'infractionType': infractionType,
      },
    );

    return CheatingHistoryResponse.fromJson(response.data);
  }

  InfractionType _mapBehaviorToInfractionType(CheatingBehavior behavior) {
    const behaviorToInfractionMap = {
      CheatingBehavior.lookingLeft: InfractionType.face,
      CheatingBehavior.lookingRight: InfractionType.face,
      CheatingBehavior.noFaceDetected: InfractionType.face,
      CheatingBehavior.multipleFaces: InfractionType.face,
      CheatingBehavior.pipMode: InfractionType.switchTab,
      CheatingBehavior.switchTab: InfractionType.switchTab,
      CheatingBehavior.appMinimized: InfractionType.switchTab,
    };

    return behaviorToInfractionMap[behavior] ?? InfractionType.face;
  }
}
