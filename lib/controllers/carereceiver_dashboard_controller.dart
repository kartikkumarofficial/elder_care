import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../services/location_service.dart';

class CareReceiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final LocationService _locationService = LocationService();
  Timer? _locationUpdateTimer;

  // Observables for UI state
  final isLoading = true.obs;
  final userName = ''.obs;
  final careId = ''.obs;
  final RxList<Task> tasks = <Task>[].obs;

  // Observables for Location Sharing Status
  final isSharingLocation = false.obs;
  final locationStatusMessage = "Initializing...".obs;

  @override
  void onInit() {
    super.onInit();
    // Run the full refresh logic when the controller is first created.
    refreshAllData();
  }

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  /// Public method to handle a full refresh of the dashboard.
  /// This will be called by the RefreshIndicator.
  Future<void> refreshAllData() async {
    print('[CareReceiverDashboardController] Refreshing all data...');
    // Cancel any existing timer to prevent duplicates.
    _locationUpdateTimer?.cancel();

    // Re-run the initial setup logic concurrently.
    await Future.wait([
      fetchInitialData(),
      startAutomaticLocationSharing(),
    ]);
    print('[CareReceiverDashboardController] Refresh complete.');
  }

  /// Starts the automatic location sharing process.
  Future<void> startAutomaticLocationSharing() async {
    bool permissionsGranted = await _locationService.requestPermissions();
    if (permissionsGranted) {
      locationStatusMessage.value = "Permissions granted. Sharing location...";
      isSharingLocation.value = true;
      await _locationService.updateLocationInSupabase();
      _locationUpdateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        _locationService.updateLocationInSupabase();
        locationStatusMessage.value = "Location updated at ${TimeOfDay.now().format(Get.context!)}";
      });
    } else {
      locationStatusMessage.value = "Permission denied. Location is not being shared.";
      isSharingLocation.value = false;
    }
  }

  /// Fetches the user's profile and their associated tasks.
  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        isLoading.value = false;
        return;
      }
      final profileResponse = await supabase
          .from('users')
          .select('full_name, care_id')
          .eq('id', currentUser.id)
          .single();
      userName.value = profileResponse['full_name'] ?? 'User';
      careId.value = profileResponse['care_id'] ?? 'N/A';
      await fetchTasks();
    } catch (e) {
      Get.snackbar('Error', 'Could not load dashboard data.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches tasks for the current user.
  Future<void> fetchTasks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final response = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('task_time', ascending: true);
      tasks.value = (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch reminders.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// Toggles the completion status of a task.
  Future<void> toggleTaskCompletion(int taskId, bool newStatus) async {
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      tasks[taskIndex].isCompleted = newStatus;
      tasks.refresh();
      await supabase.from('tasks').update({'is_completed': newStatus}).eq('id', taskId);
    }
  }

  /// Adds a new task for the current user.
  Future<void> addTask(String title, TimeOfDay time) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final response = await supabase
          .from('tasks')
          .insert({
        'user_id': userId,
        'task_title': title,
        'task_time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      }).select();
      final newTask = Task.fromJson((response as List).first);
      tasks.add(newTask);
      tasks.sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
    } catch (e) {
      Get.snackbar('Error', 'Failed to add reminder.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
