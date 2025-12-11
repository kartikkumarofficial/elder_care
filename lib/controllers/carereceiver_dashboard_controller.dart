import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task_model.dart';
import '../services/location_service.dart';

class CareReceiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final LocationService _locationService = LocationService();

  Timer? _locationUpdateTimer;

  // -----------------------------
  // UI Observables
  // -----------------------------
  final isLoading = true.obs;
  final userName = ''.obs;
  final careId = ''.obs;



  // Location sharing state
  final isSharingLocation = false.obs;
  final locationStatusMessage = "Initializing...".obs;

  @override
  void onInit() {
    super.onInit();
    refreshAllData(); // Full startup routine
  }

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  // =========================================================
  // PUBLIC → Called by RefreshIndicator to reload all sections
  // =========================================================
  Future<void> refreshAllData() async {
    print('[CareReceiverDashboard] Refreshing all data...');

    // Prevent duplicate timers
    _locationUpdateTimer?.cancel();

    await Future.wait([
      fetchInitialData(),
      startAutomaticLocationSharing(),
    ]);

    print('[CareReceiverDashboard] Refresh complete.');
  }

  // =========================================================
  // START AUTOMATIC BACKGROUND LOCATION SHARING
  // =========================================================
  Future<void> startAutomaticLocationSharing() async {
    bool permissionGranted = await _locationService.requestPermissions();

    if (!permissionGranted) {
      isSharingLocation.value = false;
      locationStatusMessage.value = "Permission denied. Unable to share location.";
      return;
    }

    isSharingLocation.value = true;
    locationStatusMessage.value = "Sharing location...";

    // Initial update
    await _locationService.updateLocationInSupabase();

    // Update every 2 minutes
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _locationService.updateLocationInSupabase();
      locationStatusMessage.value =
      "Updated at ${TimeOfDay.now().format(Get.context!)}";
    });
  }

  // =========================================================
  // FETCH USER PROFILE + CARE ID
  // =========================================================
  Future<void> fetchInitialData() async {
    isLoading.value = true;

    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        isLoading.value = false;
        return;
      }

      // Fetch profile
      final profile = await supabase
          .from('users')
          .select('full_name, care_id')
          .eq('id', currentUser.id)
          .single();

      userName.value = profile['full_name'] ?? "User";
      careId.value = profile['care_id'] ?? "N/A";

    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not load dashboard data.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // FETCH REMINDER TASKS
  // =========================================================


  // =========================================================
  // TOGGLE TASK COMPLETION
  // =========================================================


  // =========================================================
  // ADD NEW TASK
  // =========================================================


  //pedometer - tracking steps and sending to supabase
  RxInt steps = 0.obs;

  Future<void> uploadStepsToSupabase(int steps) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client
        .from("steps_data")
        .insert({
      "user_id": userId,
      "steps": steps,
    });
  }


  void initStepTracking() {
    Pedometer.stepCountStream.listen((event) async {
      steps.value = event.steps;

      await uploadStepsToSupabase(event.steps);
    });
  }

}
