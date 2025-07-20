import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart'; // We will create this model

class CareReceiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Observables for UI state
  final isLoading = true.obs;
  final userName = ''.obs;
  final careId = ''.obs;
  final RxList<Task> tasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  /// Fetches the user's profile and their associated tasks.
  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        // Handle case where user is not logged in
        isLoading.value = false;
        return;
      }

      // Fetch the receiver's own profile data
      final profileResponse = await supabase
          .from('users')
          .select('full_name, care_id')
          .eq('id', currentUser.id)
          .single();

      userName.value = profileResponse['full_name'] ?? 'User';
      careId.value = profileResponse['care_id'] ?? 'N/A';

      // After fetching profile, fetch the tasks
      await fetchTasks();

    } catch (e) {
      Get.snackbar('Error', 'Could not load dashboard data.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches tasks for the current user from the 'tasks' table.
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

  /// Toggles the completion status of a task and updates it in Supabase.
  Future<void> toggleTaskCompletion(int taskId, bool newStatus) async {
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      tasks[taskIndex].isCompleted = newStatus;
      tasks.refresh();

      await supabase
          .from('tasks')
          .update({'is_completed': newStatus})
          .eq('id', taskId);
    }
  }

  /// Adds a new task for the current user to the 'tasks' table.
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
      })
          .select();

      final newTask = Task.fromJson((response as List).first);
      tasks.add(newTask);
      // Sort tasks by time to maintain order
      tasks.sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
    } catch (e) {
      Get.snackbar('Error', 'Failed to add reminder.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
