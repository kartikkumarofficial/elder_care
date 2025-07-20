import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../services/location_service.dart'; // Make sure this is imported

class CareReceiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final LocationService _locationService = LocationService(); // Add LocationService instance
  Timer? _locationUpdateTimer; // Add Timer for background updates

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
    // Fetch dashboard data and start location sharing simultaneously
    fetchInitialData();
    _startAutomaticLocationSharing();
  }

  @override
  void onClose() {
    // IMPORTANT: Cancel the timer to prevent memory leaks
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  /// Starts the automatic location sharing process.
  Future<void> _startAutomaticLocationSharing() async {
    bool permissionsGranted = await _locationService.requestPermissions();
    if (permissionsGranted) {
      locationStatusMessage.value = "Sharing location...";
      isSharingLocation.value = true;
      await _locationService.updateLocationInSupabase(); // Initial update
      // Start a timer to update every 2 minutes
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
