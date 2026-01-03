import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../modules/tasks/views/alarm_ring_screen.dart';
import '../../modules/tasks/views/alarm_screen.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final parts = details.payload!.split('||');

          final label = parts.isNotEmpty ? parts[0] : '';
          final time = parts.length > 1 ? parts[1] : '';

          Get.to(() => AlarmScreen(
            label: label,
            time: time,
          ));
        }
      },
    );

    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Foreground service channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'foreground_service',
          'Background Monitoring',
          description: 'Keeps ElderCare alarms running',
          importance: Importance.low,
        ),
      );

      // Alarm channel
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'task_alarm_v3',
          'Task Alarms',
          description: 'Alarm notifications for tasks',
          importance: Importance.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('alarm'),
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 500, 500, 500]),
        ),
      );
    }

    // Android 13+
    await androidPlugin?.requestNotificationsPermission();

    // Android 14+
    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> startForegroundService() async {
    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    await androidPlugin.startForegroundService(
      9999,
      'ElderCare active',
      'Monitoring scheduled tasks',
      notificationDetails: const AndroidNotificationDetails(
        'foreground_service',
        'Background Monitoring',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
      ),
    );
  }

  static Future<void> stopForegroundService() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.stopForegroundService();
  }

  static Future<void> schedule({
    required int id,
    required String title,
    required DateTime dateTime,
    required bool vibrate,
  }) async {
    final formattedTime =
        '${dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12}'
        ':${dateTime.minute.toString().padLeft(2, '0')} '
        '${dateTime.hour >= 12 ? 'PM' : 'AM'}';

    final payload = '$title||$formattedTime';

    await _plugin.zonedSchedule(
      id,
      'Task Reminder',
      title,
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_alarm_v3',
          'Task Alarms',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          sound: const RawResourceAndroidNotificationSound('alarm'),
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          enableVibration: vibrate,
          vibrationPattern: vibrate
              ? Int64List.fromList([0, 500, 500, 500, 500])
              : null,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> scheduleWithRepeat({
    required int baseId,
    required String title,
    required DateTime dateTime,
    required bool vibrate,
    required String repeatType,
    required List<String> repeatDays,
  }) async {
    await schedule(
      id: baseId,
      title: title,
      dateTime: dateTime,
      vibrate: vibrate,
    );

    if (repeatType == 'none') return;

    if (repeatType == 'tomorrow') {
      await schedule(
        id: baseId + 1,
        title: title,
        dateTime: dateTime.add(const Duration(days: 1)),
        vibrate: vibrate,
      );
    }

    if (repeatType == 'daily') {
      for (int i = 1; i <= 7; i++) {
        await schedule(
          id: baseId + i,
          title: title,
          dateTime: dateTime.add(Duration(days: i)),
          vibrate: vibrate,
        );
      }
    }

    if (repeatType == 'custom') {
      final weekdayMap = {
        'Mon': DateTime.monday,
        'Tue': DateTime.tuesday,
        'Wed': DateTime.wednesday,
        'Thu': DateTime.thursday,
        'Fri': DateTime.friday,
        'Sat': DateTime.saturday,
        'Sun': DateTime.sunday,
      };

      for (int i = 1; i <= 14; i++) {
        final next = dateTime.add(Duration(days: i));
        final label = weekdayMap.entries
            .firstWhere((e) => e.value == next.weekday,
            orElse: () => const MapEntry('', 0))
            .key;

        if (repeatDays.contains(label)) {
          await schedule(
            id: baseId + i,
            title: title,
            dateTime: next,
            vibrate: vibrate,
          );
        }
      }
    }
  }

  static Future<List<PendingNotificationRequest>>
  debugPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
