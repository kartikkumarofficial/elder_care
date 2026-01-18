import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../events/controllers/events_controller.dart';
import '../../tasks/controllers/task_controller.dart';
import 'activity_controller.dart';

class ReceiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // USER INFO
  // ─────────────────────────────────────────────
  final userName = ''.obs;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  // ─────────────────────────────────────────────
  // MOOD
  // ─────────────────────────────────────────────
  final selectedMood = ''.obs;
  final moodSubmittedToday = false.obs;

  // ─────────────────────────────────────────────
  // DEVICE STATUS
  // ─────────────────────────────────────────────
  final Battery _battery = Battery();
  final batteryLevel = 0.obs;
  final isCharging = false.obs;
  final isDeviceConnected = false.obs;
  DateTime? lastDeviceSync;

  // ─────────────────────────────────────────────
  // LOCATION SHARING
  // ─────────────────────────────────────────────
  Timer? _locationTimer;
  bool _locationStarted = false;
  final isSharingLocation = false.obs;
  final locationStatusMessage = "Initializing...".obs;

  // ─────────────────────────────────────────────
  // STEPS
  // ─────────────────────────────────────────────
  StreamSubscription<StepCount>? _stepSub;
  Timer? _stepsFlushTimer;
  bool _stepsStarted = false;
  int _latestSteps = 0;

  // ─────────────────────────────────────────────
  // UI STATE
  // ─────────────────────────────────────────────
  final isLoading = false.obs;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    debugPrint("🚀 ReceiverDashboardController initialized");
    loadDashboard();
  }

  @override
  void onClose() {
    debugPrint("🧹 ReceiverDashboardController disposed");
    _stepSub?.cancel();
    _stepsFlushTimer?.cancel();
    _locationTimer?.cancel();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // DASHBOARD LOAD
  // ─────────────────────────────────────────────
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

      debugPrint("✅ Dashboard load complete");
    } catch (e) {
      debugPrint("❌ ReceiverDashboard load error: $e");
    } finally {
      isLoading.value = false;
    }
  }
  //for mood section - commented

  // ─────────────────────────────────────────────
  // MOOD
  // ─────────────────────────────────────────────
  // Future<void> checkTodayMood() async {
  //   final user = supabase.auth.currentUser;
  //   if (user == null) return;
  //
  //   final today = DateTime.now().toIso8601String().substring(0, 10);
  //
  //   final res = await supabase
  //       .from('mood_tracking')
  //       .select('mood')
  //       .eq('user_id', user.id)
  //       .eq('mood_date', today)
  //       .maybeSingle();
  //
  //   if (res != null) {
  //     selectedMood.value = res['mood'];
  //     moodSubmittedToday.value = true;
  //     debugPrint("🙂 Mood loaded: ${res['mood']}");
  //   } else {
  //     moodSubmittedToday.value = false;
  //     debugPrint("🙂 No mood for today yet");
  //   }
  // }

  // Future<void> submitMood(String mood) async {
  //   final user = supabase.auth.currentUser;
  //   if (user == null) return;
  //
  //   final today = DateTime.now().toIso8601String().substring(0, 10);
  //
  //   selectedMood.value = mood;
  //   moodSubmittedToday.value = true;
  //
  //   await supabase.from('mood_tracking').upsert(
  //     {
  //       'user_id': user.id,
  //       'mood': mood,
  //       'mood_date': today,
  //     },
  //     onConflict: 'user_id,mood_date',
  //   );
  //
  //   debugPrint("🙂 Mood updated → $mood");
  // }

  // ─────────────────────────────────────────────
  // DEVICE STATUS
  // ─────────────────────────────────────────────
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

  // ─────────────────────────────────────────────
  // LOCATION SHARING (LOGGED)
  // ─────────────────────────────────────────────
  Future<void> startAutomaticLocationSharing() async {
    if (_locationStarted) return;
    _locationStarted = true;

    debugPrint("📍 Starting location sharing");

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationStatusMessage.value = "Enable GPS";
      debugPrint("❌ Location services disabled");
      return;
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

  // ─────────────────────────────────────────────
  // STEPS
  // ─────────────────────────────────────────────
  Future<void> startStepTracking() async {
    if (_stepsStarted) return;
    _stepsStarted = true;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final permission = await Permission.activityRecognition.request();
    if (!permission.isGranted) {
      debugPrint("❌ Step permission denied");
      return;
    }

    _stepSub = Pedometer.stepCountStream.listen((event) {
      _latestSteps = event.steps;
    });

    _stepsFlushTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) => _flushStepsToDB(),
    );

    debugPrint("🚶 Step tracking started");
  }

  Future<void> _flushStepsToDB() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateKey =
    DateTime(now.year, now.month, now.day).toIso8601String().substring(0, 10);

    await supabase.from('steps_data').upsert(
      {
        'user_id': user.id,
        'date': dateKey,
        'steps': _latestSteps,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,date',
    );
    Get.find<ActivityController>().markActive(syncToServer: false);

    debugPrint("🚶 Steps synced: $_latestSteps");
  }

  // ─────────────────────────────────────────────
  // SOS
  // ─────────────────────────────────────────────
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
      debugPrint("🔄 Pull-to-refresh started");

      final user = supabase.auth.currentUser;
      if (user == null) return;

      // 🔹 Device status (battery + charging)
      await syncDeviceStatus();

      // 🔹 Device connectivity (online / offline)
      await refreshDeviceConnectionStatus();

      // 🔹 Mood re-check
      await checkTodayMood();

      // 🔹 Tasks (via TaskController)
      if (Get.isRegistered<TaskController>()) {
        await Get.find<TaskController>()
            .loadTasksForReceiver(user.id);
      }

      // 🔹 Events (if controller exists)
      if (Get.isRegistered<EventsController>()) {
        await Get.find<EventsController>().loadEvents();
      }

      debugPrint("✅ Pull-to-refresh completed");
    } catch (e) {
      debugPrint("❌ Refresh failed: $e");
    } finally {
      isLoading.value = false;
    }
  }






}
