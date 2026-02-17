import 'package:flutter/services.dart';

class NativeAlarmService {
  static const _channel = MethodChannel('eldercare/alarm');

  static Future<void> schedule({
    required String alarmId,
    required DateTime dateTime,
  }) async {
    await _channel.invokeMethod('scheduleAlarm', {
      'alarmId': alarmId,
      'triggerTime': dateTime.millisecondsSinceEpoch,
    });
  }

  static Future<void> cancel(String alarmId) async {
    await _channel.invokeMethod('cancelAlarm', {
      'alarmId': alarmId,
    });
  }
}
