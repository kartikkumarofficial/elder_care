import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Top-level background message handler for FCM.
/// Must be outside any class.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("📩 Background message received: ${message.messageId}");
  // Note: Native side (MyFirebaseMessagingService.kt) also handles this.
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static final _supabase = Supabase.instance.client;

  static Future<void> init() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("🔔 Notification permission granted");
    } else {
      debugPrint("❌ Notification permission denied");
    }

    // 2. Initialize Local Notifications for Foreground display
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Foreground message received: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // 5. Handle notification clicks when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🖱️ Notification tapped (Background): ${message.data}");
      _handleNotificationClick(message.data);
    });

    // Check if app was opened from a terminated state via notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("🖱️ Notification tapped (Terminated): ${initialMessage.data}");
      _handleNotificationClick(initialMessage.data);
    }

    // 6. Sync Token
    await syncFcmToken();
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && !kIsWeb) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel', // Matches native side
            'General Notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint("🖱️ Local notification tapped: ${response.payload}");
    // Parse payload if needed and navigate
  }

  static void _handleNotificationClick(Map<String, dynamic> data) {
    // Implementation for deep linking or navigation based on data
    final String? type = data['type'];
    if (type == 'chat') {
      // Get.toNamed('/chat', arguments: data['chat_id']);
    }
  }

  static Future<void> syncFcmToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        debugPrint("📱 FCM TOKEN: $token");
        await _saveTokenToDatabase(token);
      }
    } catch (e) {
      debugPrint("❌ Error syncing FCM token: $e");
    }
  }

  static Future<void> _saveTokenToDatabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('users').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      debugPrint("✅ FCM token synced for user: $userId");
    } catch (e) {
      debugPrint("❌ Failed to save FCM token to DB: $e");
    }
  }
}
