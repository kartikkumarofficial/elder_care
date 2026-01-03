import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
      ),
    );

    //  CREATE FOREGROUND SERVICE CHANNEL
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'foreground_service', // MUST match service channel
          'Background Monitoring',
          description:
          'Keeps ElderCare alarms running in the background',
          importance: Importance.low, // ⚠️ MUST NOT be null
        ),
      );
    }

    // Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // Android 14+
    await androidPlugin?.requestExactAlarmsPermission();
  }


  //  DEBUG (temporary)
  static Future<List<PendingNotificationRequest>>
  debugPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }

  //  START foreground service
  static Future<void> startForegroundService() async {
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'foreground_service', // MUST exist
        'Background Monitoring',
        channelDescription:
        'Keeps ElderCare alarms running in background',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
      ),
    );

    await androidPlugin.startForegroundService(
      9999,
      'ElderCare active',
      'Monitoring scheduled tasks',
      notificationDetails: notificationDetails.android
    );
  }



  //  STOP foreground service
  static Future<void> stopForegroundService() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.stopForegroundService();
  }

  //  Schedule alarm
  static Future<void> schedule({
    required int id,
    required String title,
    required DateTime dateTime,
    required bool vibrate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      'Task Reminder',
      title,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_alarm_v2',
          'Task Alarms',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('soothing_alarm'),
          vibrationPattern: vibrate
              ? Int64List.fromList([0, 500, 500, 500, 500])
              : null,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }


  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
