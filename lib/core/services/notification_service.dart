import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final _supabase = Supabase.instance.client;

  static Future<void> init() async {
    // 1. Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("🔔 Notification permission granted");
      // 2. Sync token if user is logged in
      await syncFcmToken();
    } else {
      debugPrint("❌ Notification permission denied");
    }

    // 3. Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(newToken);
    });
  }

  /// Fetches the current FCM token and saves it to Supabase if a user is logged in.
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
