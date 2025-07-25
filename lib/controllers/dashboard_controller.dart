import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// You'll need a simple data model for your tasks
class Task {
  final int id;
  final String title;
  final TimeOfDay time;
  bool isCompleted;

  Task({required this.id, required this.title, required this.time, this.isCompleted = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['task_time'] as String).split(':');
    return Task(
      id: json['id'],
      title: json['task_title'],
      time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      isCompleted: json['is_completed'],
    );
  }
}

class DashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Observables for the UI
  final isLoading = true.obs;
  final userName = ''.obs;
  final careId = ''.obs;
  final RxList<Task> tasks = <Task>[].obs;

  // Internal state
  String? _userId; // The ID of the user whose data is being displayed

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      // Fetch the current user's details to see if they are a caregiver or receiver
      final userResponse = await supabase
          .from('users')
          .select('role, linked_user_id')
          .eq('id', currentUser.id)
          .single();

      final userRole = userResponse['role'];
      final linkedUserId = userResponse['linked_user_id'];

      if (userRole == 'caregiver' && linkedUserId != null) {
        // If caregiver, fetch the linked receiver's data
        _userId = linkedUserId;
      } else {
        // If receiver, use their own ID
        _userId = currentUser.id;
      }

      if (_userId != null) {
        // Fetch the profile data of the person being cared for
        final profileResponse = await supabase
            .from('users')
            .select('full_name, care_id')
            .eq('id', _userId!)
            .single();

        userName.value = profileResponse['full_name'] ?? 'User';
        careId.value = profileResponse['care_id'] ?? 'N/A';

        // Fetch the tasks for that user
        await fetchTasks();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load dashboard data.', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTasks() async {
    if (_userId == null) return;
    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', _userId!)
        .order('task_time', ascending: true);

    tasks.value = (response as List).map((json) => Task.fromJson(json)).toList();
  }

  Future<void> toggleTaskCompletion(int taskId, bool newStatus) async {
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      tasks[taskIndex].isCompleted = newStatus;
      tasks.refresh(); // Update the UI immediately

      await supabase
          .from('tasks')
          .update({'is_completed': newStatus})
          .eq('id', taskId);
    }
  }

  Future<void> addTask(String title, TimeOfDay time) async {
    if (_userId == null) return;

    final response = await supabase
        .from('tasks')
        .insert({
      'user_id': _userId,
      'task_title': title,
      'task_time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      'created_by': supabase.auth.currentUser!.id, // Track who created it
    })
        .select();

    // Add the new task to the local list and refresh UI
    final newTask = Task.fromJson((response as List).first);
    tasks.add(newTask);
    tasks.sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));

  }
}
