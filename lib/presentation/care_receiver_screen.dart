import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Data model for your tasks
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

// Renamed from DashboardController
class CareReceiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final userName = ''.obs;
  final careId = ''.obs;
  final RxList<Task> tasks = <Task>[].obs;

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

      // Fetch the receiver's own data
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

  Future<void> fetchTasks() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('task_time', ascending: true);

    tasks.value = (response as List).map((json) => Task.fromJson(json)).toList();
  }

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

  Future<void> addTask(String title, TimeOfDay time) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

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
    tasks.sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));
  }
}
