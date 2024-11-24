import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  Function(String?)? _onNotificationTap;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('🔄 NotificationService already initialized');
      return;
    }
    
    print('🔔 NotificationService: Initializing...');
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final initialized = await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📱 Notification tapped with payload: ${response.payload}');
        if (_onNotificationTap != null) {
          _onNotificationTap!(response.payload);
        }else{
          print('1111');
        }
      },
    );

    _isInitialized = initialized ?? false;
    print('✅ NotificationService initialized: $_isInitialized');
  }

  void setOnNotificationTap(Function(String?) callback) {
    print('🔔 Setting notification tap callback');
    _onNotificationTap = callback;
    print('🔔 Callback registered: ${_onNotificationTap != null}');
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      print('⚠️ NotificationService chưa được khởi tạo');
      await initialize();
    }

    print('📤 Đang gửi notification:');
    print('- ID: $id');
    print('- Title: $title'); 
    print('- Body: $body');
    print('- Payload: $payload');

    try {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Channel',
        importance: Importance.high,
        priority: Priority.high,
      );
      print('📱 Android details đã được cấu hình');

      const iosDetails = DarwinNotificationDetails();
      print('📱 iOS details đã được cấu hình');

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
      print('✅ Notification đ được gửi thành công');
    } catch (e) {
      print('❌ Lỗi khi gửi notification: $e');
    }
  }

  // Lên lịch notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Hủy một notification cụ thể
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Hủy tất cả notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 