import 'package:exam_guardian/configs/data_source.dart';
import 'package:exam_guardian/configs/dio_client.dart';
import 'package:exam_guardian/features/common/models/notification.dart';

class NotiRepository {
  Future<NotificationResponse> getNotis(String clientId, String token, {String? status, int page = 1}) async {
    final response = await DioClient.performRequest(
      ApiUrls.getNotifications,
      clientId: clientId,
      token: token,
      queryParameters: {'status': status, 'page': page},
    );
    return NotificationResponse.fromJson(response.data);
  }
}

