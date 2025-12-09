import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Task {
  final int id;
  final String title;
  final TimeOfDay time;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['task_time'] as String).split(':');

    return Task(
      id: json['id'],
      title: json['task_title'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      isCompleted: json['is_completed'],
    );
  }
}

class DashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Reactive UI variables
  final isLoading = true.obs;
  final userName = ''.obs;
  final careId = ''.obs;
  final RxList<Task> tasks = <Task>[].obs;

  // ID of the user whose dashboard is displayed
  String? _displayUserId;

  @override
  void onInit() {
    super.onInit();
    print("[DashboardController] onInit()");
    fetchInitialData();
  }

  @override
  void onClose() {
    print("[DashboardController] onClose()");
    super.onClose();
  }

  // -------------------------------------------------------------
  // FETCH ROLE → DETERMINE WHICH USER DASHBOARD TO SHOW
  // -------------------------------------------------------------
  Future<void> fetchInitialData() async {
    isLoading.value = true;

    try {
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        isLoading.value = false;
        return;
      }

      // Fetch user's role
      final userRow = await supabase
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      final role = userRow['role'];

      // CASE 1 → CAREGIVER
      if (role == "caregiver") {
        final linkRow = await supabase
            .from('care_links')
            .select('receiver_id')
            .eq('caregiver_id', currentUser.id)
            .maybeSingle();

        if (linkRow == null || linkRow['receiver_id'] == null) {
          userName.value = "Not Linked";
          careId.value = "N/A";
          isLoading.value = false;
          return;
        }

        _displayUserId = linkRow['receiver_id'];
      }
      // CASE 2 → RECEIVER
      else {
        _displayUserId = currentUser.id;
      }

      // Now fetch profile + tasks for that user
      await _fetchProfile();
      await fetchTasks();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not load dashboard.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------------------------------------
  // FETCH PROFILE OF DISPLAY USER
  // -------------------------------------------------------------
  Future<void> _fetchProfile() async {
    if (_displayUserId == null) return;

    final profile = await supabase
        .from('users')
        .select('full_name, care_id')
        .eq('id', _displayUserId!)
        .single();

    userName.value = profile['full_name'] ?? "User";
    careId.value = profile['care_id'] ?? "N/A";
  }

  // -------------------------------------------------------------
  // FETCH TASKS FOR DISPLAY USER
  // -------------------------------------------------------------
  Future<void> fetchTasks() async {
    if (_displayUserId == null) return;

    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', _displayUserId!)
        .order('task_time', ascending: true);

    tasks.value =
        (response as List).map((json) => Task.fromJson(json)).toList();
  }

  // -------------------------------------------------------------
  // TOGGLE TASK COMPLETION
  // -------------------------------------------------------------
  Future<void> toggleTaskCompletion(int taskId, bool newStatus) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;

    tasks[idx].isCompleted = newStatus;
    tasks.refresh();

    await supabase
        .from('tasks')
        .update({'is_completed': newStatus})
        .eq('id', taskId);
  }

  // -------------------------------------------------------------
  // ADD NEW TASK
  // -------------------------------------------------------------
  Future<void> addTask(String title, TimeOfDay time) async {
    if (_displayUserId == null) return;

    final formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

    final response = await supabase
        .from('tasks')
        .insert({
      'user_id': _displayUserId!,
      'task_title': title,
      'task_time': formattedTime,
      'created_by': supabase.auth.currentUser!.id,
    })
        .select();

    final newTask = Task.fromJson((response as List).first);
    tasks.add(newTask);

    // sort by time
    tasks.sort((a, b) =>
        (a.time.hour * 60 + a.time.minute)
            .compareTo(b.time.hour * 60 + b.time.minute));
  }
}
