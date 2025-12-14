import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint("🔔 Notification permission: ${settings.authorizationStatus}");

    // Get FCM token
    final token = await _fcm.getToken();
    debugPrint("📱 FCM TOKEN: $token");
  }
}
