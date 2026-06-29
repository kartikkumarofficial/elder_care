import 'package:flutter/services.dart';

class NativeAlarmService {
  static const _channel = MethodChannel('eldercare/alarm');

  static Future<void> schedule({
    required String alarmId,
    required DateTime dateTime,
    required String title,
    String? instructions,
    String repeatType = 'none',
    List<String> repeatDays = const [],
  }) async {
    await _channel.invokeMethod('scheduleAlarm', {
      'alarmId': alarmId,
      'triggerTime': dateTime.millisecondsSinceEpoch,
      'title': title,
      'instructions': instructions,
      'repeatType': repeatType,
      'repeatDays': repeatDays,
    });
  }

  static Future<void> cancel(String alarmId) async {
    await _channel.invokeMethod('cancelAlarm', {
      'alarmId': alarmId,
    });
  }

  static Future<void> checkBatteryOptimizations() async {
    await _channel.invokeMethod('checkBatteryOptimizations');
  }
}
