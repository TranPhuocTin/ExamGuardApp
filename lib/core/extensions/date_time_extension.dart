import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  static const int vietnamTimeZoneOffset = 7;

  DateTime get toVietnamTime => add(Duration(hours: vietnamTimeZoneOffset));
  DateTime get toUTC => subtract(Duration(hours: vietnamTimeZoneOffset));

  String get formatted => DateFormat('yyyy-MM-dd HH:mm').format(toVietnamTime);

  bool get isFuture => isAfter(DateTime.now());
  bool get isPast => isBefore(DateTime.now());
  
  bool isAfterDate(DateTime other) => toVietnamTime.isAfter(other.toVietnamTime);
  bool isBeforeDate(DateTime other) => toVietnamTime.isBefore(other.toVietnamTime);

  static DateTime? fromString(String date) {
    try {
      return DateFormat('yyyy-MM-dd HH:mm').parse(date).toUTC;
    } catch (e) {
      return null;
    }
  }
} 