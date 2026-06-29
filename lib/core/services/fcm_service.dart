import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  static final _supabase = Supabase.instance.client;

  /// Sends a native alarm command to another device
  static Future<void> sendRemoteAlarm({
    required String receiverId,
    required String alarmId,
    required DateTime time,
    required String title,
    String? instructions,
    String repeatType = 'none',
    List<String> repeatDays = const [],
    bool isCancel = false,
  }) async {
    await _invoke(
      receiverId: receiverId,
      data: {
        'type': isCancel ? 'cancel_alarm' : 'schedule_alarm',
        'alarm_id': alarmId,
        'alarm_time': time.millisecondsSinceEpoch.toString(),
        'title': title,
        if (instructions != null) 'instructions': instructions,
        'repeat_type': repeatType,
        'repeat_days': jsonEncode(repeatDays),
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
    );
  }

  /// Sends a standard notification
  static Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, String>? extraData,
  }) async {
    await _invoke(
      receiverId: receiverId,
      data: {
        'type': type,
        'title': title,
        'body': body,
        ...?extraData,
      },
      notification: {
        'title': title,
        'body': body,
      },
    );
  }

  static Future<void> _invoke({
    required String receiverId,
    required Map<String, String> data,
    Map<String, String>? notification,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-fcm',
        body: {
          'receiverId': receiverId,
          'data': data,
          if (notification != null) 'notification': notification,
        },
      );

      if (response.status != 200) {
        debugPrint("❌ FCM Edge Function error: ${response.data}");
      } else {
        debugPrint("✅ FCM sent to $receiverId");
      }
    } catch (e) {
      debugPrint("❌ FCM Send Error: $e");
    }
  }
}
