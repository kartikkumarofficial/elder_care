import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../events/controllers/events_controller.dart';
import '../../events/widgets/healthconnect_dialog.dart';
import '../../tasks/controllers/task_controller.dart';
import 'activity_controller.dart';

class ReceiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final TaskController taskController = Get.put(TaskController(), permanent: true);

  // user info
  final userName = ''.obs;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  // mood
  final selectedMood = ''.obs;
  final moodSubmittedToday = false.obs;
  
// MOOD CONFIG (ORDERED: HAPPY → SAD)

  final List<Map<String, String>> moodOptions = [
    {'key': 'very_happy', 'emoji': '😄'},
    {'key': 'happy', 'emoji': '😃'},
    {'key': 'neutral', 'emoji': '😐'},
    {'key': 'sad', 'emoji': '😔'},
    {'key': 'very_sad', 'emoji': '😣'},
  ];



  // DEVICE STATUS
  
  final Battery _battery = Battery();
  final batteryLevel = 0.obs;
  final isCharging = false.obs;
  final isDeviceConnected = false.obs;
  DateTime? lastDeviceSync;

  
  // LOCATION SHARING
  
  Timer? _locationTimer;
  bool _locationStarted = false;
  final isSharingLocation = false.obs;
  final locationStatusMessage = "Initializing...".obs;

  
  // STEPS
  
  StreamSubscription<StepCount>? _stepSub;
  Timer? _stepsFlushTimer;
  bool _stepsStarted = false;
  int _latestSteps = 0;
  int _baselineSteps = 0;
  String _baselineDate = "";
  
  // UI STATE
  
  final isLoading = false.obs;

  
  // INIT
  
  @override
  void onInit() {
    super.onInit();
    debugPrint("🚀 ReceiverDashboardController initialized");
    loadDashboard();

    syncFcmToken();
  }

  @override
  void onClose() {
    debugPrint("🧹 ReceiverDashboardController disposed");
    _stepSub?.cancel();
    _stepsFlushTimer?.cancel();
    _locationTimer?.cancel();
    super.onClose();
  }

  
  // DASHBOARD LOAD
  
  Future<void> loadDashboard() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      debugPrint("🔄 Loading receiver dashboard");

      final user = supabase.auth.currentUser;
      if (user == null) {
        debugPrint("❌ No authenticated user");
        return;
      }

      final profile = await supabase
          .from('users')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      userName.value = profile?['full_name'] ?? '';

      await checkTodayMood();
      await syncDeviceStatus();
      await refreshDeviceConnectionStatus();
      await startAutomaticLocationSharing();
      await startStepTracking();
      await Get.find<EventsController>()
          .loadEventsForReceiver(user.id);

      debugPrint("✅ Dashboard load complete");
    } catch (e) {
      debugPrint("❌ ReceiverDashboard load error: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  // DEVICE STATUS
  
  Future<void> syncDeviceStatus() async {
    if (lastDeviceSync != null &&
        DateTime.now().difference(lastDeviceSync!).inMinutes < 5) {
      return;
    }

    lastDeviceSync = DateTime.now();

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final level = await _battery.batteryLevel;
    final chargingState = await _battery.batteryState;

    batteryLevel.value = level;
    isCharging.value = chargingState == BatteryState.charging;

    await supabase.from('device_status').upsert(
      {
        'user_id': user.id,
        'battery_level': level,
        'charging': isCharging.value,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );

    Get.find<ActivityController>().markActive();

    debugPrint("🔋 Battery: $level% | Charging: ${isCharging.value}");
  }

  Future<void> refreshDeviceConnectionStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('device_status')
        .select('updated_at')
        .eq('user_id', user.id)
        .maybeSingle();

    if (res == null) {
      isDeviceConnected.value = false;
      debugPrint("📡 Device offline");
      return;
    }

    final last = DateTime.parse(res['updated_at']).toLocal();
    isDeviceConnected.value =
        DateTime.now().difference(last).inMinutes <= 10;

    debugPrint("📡 Device connected: ${isDeviceConnected.value}");
  }

  
  // LOCATION SHARING (LOGGED)
  
  Future<void> startAutomaticLocationSharing() async {
    if (_locationStarted) return;
    _locationStarted = true;

    debugPrint("📍 Starting location sharing");

    final user = supabase.auth.currentUser;
    if (user == null) return;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      locationStatusMessage.value = "Enable GPS";
      await Geolocator.openLocationSettings();

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("❌ Location still disabled");
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      locationStatusMessage.value = "Permission denied";
      debugPrint("❌ Location permission denied");
      return;
    }

    debugPrint("✅ Location permission granted: $permission");
    isSharingLocation.value = true;
    locationStatusMessage.value = "Sharing location";

    await _sendLocationOnce();

    _locationTimer = Timer.periodic(
      const Duration(minutes: 2),
          (_) => _sendLocationOnce(),
    );
  }

  Future<void> _sendLocationOnce() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    debugPrint(
        "📍 Uploading location → lat: ${position.latitude}, lng: ${position.longitude}");

    await supabase.from('user_locations').upsert(
      {
        'user_id': user.id,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
    Get.find<ActivityController>().markActive();


    debugPrint("📍 Location upload successful");
  }

  
  // STEPS

  final Health _health = Health();

  Future<void> startStepTracking() async {
    if (_stepsStarted) return;
    _stepsStarted = true;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Request permission for reading step data
      final types = [HealthDataType.STEPS];

      bool requested = await _health.requestAuthorization(types);

      if (!requested) {
        debugPrint("❌ Health permission denied");
        return;
      }

      debugPrint("✅ Health permission granted");

      // fetch steps immediately
      await _fetchTodaySteps();

      // refresh every 5 minutes
      _stepsFlushTimer = Timer.periodic(
        const Duration(minutes: 5),
            (_) => _fetchTodaySteps(),
      );

      debugPrint("🚶 Health step tracking started");
    } catch (e) {
      debugPrint("❌ Health step tracking error: $e");

      if (e.toString().contains("Health Connect is not available")) {
        showHealthConnectDialog();
      }
    }
  }

  Future<void> _fetchTodaySteps() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      int steps =
          await _health.getTotalStepsInInterval(midnight, now) ?? 0;

      _latestSteps = steps;

      debugPrint("🚶 Today's steps from Health API: $steps");

      final dateKey =
      midnight.toIso8601String().substring(0, 10);

      await supabase.from('steps_data').upsert(
        {
          'user_id': user.id,
          'date': dateKey,
          'steps': steps,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,date',
      );

      Get.find<ActivityController>().markActive(syncToServer: false);

      debugPrint("🚶 Steps synced: $steps");
    } catch (e) {
      debugPrint("❌ Health step fetch error: $e");
    }
  }

  
  // SOS
  
  Future<void> sendSOS() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    debugPrint("🚨 SEND SOS tapped by ${user.id}");

    try {
      Position? position =
          await Geolocator.getLastKnownPosition() ??
              await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
                timeLimit: const Duration(seconds: 8),
              );

      if (position == null) {
        Get.snackbar(
          "Location unavailable",
          "Unable to fetch location",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      debugPrint("📍 SOS location fetched: ${position.latitude}, ${position.longitude}");

      final res = await supabase.from('sos_alerts').insert({
        'user_id': user.id,
        'lat': position.latitude,
        'lng': position.longitude,
        'message': 'Emergency SOS triggered',
        'handled': false,
      });
      Get.find<ActivityController>().markActive(syncToServer: false);

      debugPrint("✅ SOS INSERT SUCCESS: $res");

      Get.snackbar(
        "SOS Sent",
        "Caregiver has been notified",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint("❌ SOS INSERT FAILED: $e");
      Get.snackbar(
        "Error",
        "Failed to send SOS",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

// MOOD DIALOG CONTROL (2-HOUR LOGIC)

  final shouldShowMoodDialog = false.obs;
  DateTime? _lastMoodSubmissionTime;
  Future<void> checkTodayMood() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final res = await supabase
        .from('mood_tracking')
        .select('mood, updated_at')
        .eq('user_id', user.id)
        .eq('mood_date', today)
        .maybeSingle();

    if (res != null) {
      selectedMood.value = res['mood'];
      moodSubmittedToday.value = true;

      _lastMoodSubmissionTime =
          DateTime.parse(res['updated_at']).toLocal();

      final diff =
      DateTime.now().difference(_lastMoodSubmissionTime!);

      //  Only show dialog if 2+ hours passed
      shouldShowMoodDialog.value = diff.inHours >= 2;

      debugPrint(
          "🙂 Mood exists | Last updated ${diff.inMinutes} mins ago");
    } else {
      moodSubmittedToday.value = false;
      shouldShowMoodDialog.value = true; // First time today
      debugPrint("🙂 No mood yet today → dialog allowed");
    }
  }


  Future<void> submitMood(String mood) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    selectedMood.value = mood;
    moodSubmittedToday.value = true;
    shouldShowMoodDialog.value = false;
    _lastMoodSubmissionTime = DateTime.now();

    await supabase.from('mood_tracking').upsert(
      {
        'user_id': user.id,
        'mood': mood,
        'mood_date': today,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,mood_date',
    );

    Get.back();
    debugPrint("🙂 Mood updated → $mood");
  }

  Future<void> refreshDashboard() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final user = supabase.auth.currentUser;
      if (user == null) return;

      await syncDeviceStatus();
      await refreshDeviceConnectionStatus();
      await checkTodayMood();

      await Get.find<TaskController>()
          .loadTasksForReceiver(user.id);

      await Get.find<EventsController>()
          .loadEventsForReceiver(user.id);

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncFcmToken() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint("❌ Cannot sync FCM token: user not logged in");
      return;
    }

    final userId = user.id;
    debugPrint("👤 Syncing FCM for user: $userId");

    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();

    debugPrint("🔥 FCM TOKEN: $token");

    if (token != null) {
      await supabase
          .from('users')
          .update({'fcm_token': token})
          .eq('id', userId);

      debugPrint("✅ FCM token saved to Supabase");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 FCM token refreshed: $newToken");

      await supabase
          .from('users')
          .update({'fcm_token': newToken})
          .eq('id', userId);

      debugPrint("✅ Updated refreshed token in Supabase");
    });
  }

  Future<void> refreshQuickData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("🔄 Receiver quick refresh");

      await Future.wait([
        syncDeviceStatus(),
        refreshDeviceConnectionStatus(),
        checkTodayMood(),
        Get.find<TaskController>().loadTasksForReceiver(user.id),
        Get.find<EventsController>().loadEventsForReceiver(user.id),
      ]);

    } catch (e) {
      debugPrint("❌ Receiver refresh error: $e");
    }
  }





}
