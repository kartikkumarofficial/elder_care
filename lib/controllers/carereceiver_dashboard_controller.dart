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

  final RxList<Task> tasks = <Task>[].obs;

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

      await fetchTasks();

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
  Future<void> fetchTasks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('task_time', ascending: true);

      tasks.value =
          (response as List).map((json) => Task.fromJson(json)).toList();

    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not fetch reminders.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // =========================================================
  // TOGGLE TASK COMPLETION
  // =========================================================
  Future<void> toggleTaskCompletion(int taskId, bool newStatus) async {
    int index = tasks.indexWhere((t) => t.id == taskId);

    if (index == -1) return;

    tasks[index].isCompleted = newStatus;
    tasks.refresh(); // Update UI

    await supabase
        .from('tasks')
        .update({'is_completed': newStatus})
        .eq('id', taskId);
  }

  // =========================================================
  // ADD NEW TASK
  // =========================================================
  Future<void> addTask(String title, TimeOfDay time) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final formattedTime =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

      final response = await supabase
          .from('tasks')
          .insert({
        'user_id': userId,
        'task_title': title,
        'task_time': formattedTime,
      })
          .select();

      final newTask = Task.fromJson((response as List).first);

      tasks.add(newTask);

      // Sort by time
      tasks.sort((a, b) =>
          (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));

    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add reminder.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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
