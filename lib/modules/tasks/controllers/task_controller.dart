// lib/presentation/widgets/tasks/task_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/task_model.dart';


class TaskController extends GetxController {
  final supabase = Supabase.instance.client;

  // Holds the tasks for the currently loaded receiver
  RxList<TaskModel> tasks = <TaskModel>[].obs;

  // Form controllers
  final titleController = TextEditingController();
  final dateController = TextEditingController(); // iso string of combined date+time
  DateTime? pickedDate;
  TimeOfDay? pickedTime;
  RxBool alarmEnabled = false.obs;

  int? editingId;
  String? currentReceiverId;

  @override
  void onClose() {
    titleController.dispose();
    dateController.dispose();
    super.onClose();
  }

  void clearForm() {
    titleController.clear();
    dateController.clear();
    pickedDate = null;
    pickedTime = null;
    alarmEnabled.value = false;
    editingId = null;
  }

  DateTime? _combinedDateTime() {
    if (pickedDate == null || pickedTime == null) return null;
    return DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, pickedTime!.hour, pickedTime!.minute);
  }

  /// Sorting: upcoming tasks first (nearest first), then tasks without datetime.
  List<TaskModel> _sortTasks(List<TaskModel> list) {
    final withDate = <TaskModel>[];
    final withoutDate = <TaskModel>[];

    for (final t in list) {
      if (t.datetime != null && t.datetime!.isNotEmpty) {
        withDate.add(t);
      } else {
        withoutDate.add(t);
      }
    }

    withDate.sort((a, b) {
      final da = DateTime.tryParse(a.datetime!);
      final db = DateTime.tryParse(b.datetime!);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db); // nearest first
    });

    return [...withDate, ...withoutDate];
  }

  /// Load tasks for a specific receiver (call from dashboard with receiverId)
  Future<void> loadTasksForReceiver(String receiverId) async {
    currentReceiverId = receiverId;
    try {
      final res = await supabase.from('tasks').select().eq('receiver_id', receiverId).order('datetime', ascending: true);
      if (res is List) {
        final list = res.map((e) => TaskModel.fromMap(Map<String, dynamic>.from(e))).toList();
        tasks.assignAll(_sortTasks(list));
      } else {
        tasks.clear();
      }
    } catch (e) {
      debugPrint('loadTasks error: $e');
      Get.snackbar('Error', 'Failed to load tasks');
    }
  }

  Future<void> addTask() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Enter task title');
      return;
    }
    if (currentReceiverId == null) {
      Get.snackbar('Error', 'No receiver selected');
      return;
    }

    final dt = _combinedDateTime();
    final model = TaskModel(
      receiverId: currentReceiverId!,
      title: titleController.text.trim(),
      datetime: dt?.toIso8601String(),
      alarmEnabled: alarmEnabled.value,
    );

    try {
      final res = await supabase.from('tasks').insert(model.toMap()).select().single();
      if (res != null) {
        final created = TaskModel.fromMap(Map<String, dynamic>.from(res));
        tasks.insert(0, created);
        tasks.assignAll(_sortTasks(tasks));
        clearForm();
        // close dialog if open
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar('Success', 'Task added');
      }
    } catch (e) {
      debugPrint('addTask error: $e');
      Get.snackbar('Error', 'Failed to add task');
    }
  }

  Future<void> startEdit(TaskModel t) async {
    editingId = t.id;
    titleController.text = t.title;
    alarmEnabled.value = t.alarmEnabled;
    // parse datetime into pieces
    if (t.datetime != null) {
      try {
        final dt = DateTime.parse(t.datetime!);
        pickedDate = DateTime(dt.year, dt.month, dt.day);
        pickedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        dateController.text = dt.toIso8601String();
      } catch (_) {
        pickedDate = null;
        pickedTime = null;
        dateController.clear();
      }
    } else {
      pickedDate = null;
      pickedTime = null;
      dateController.clear();
    }
  }

  Future<void> confirmEdit() async {
    if (editingId == null) return;
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Enter task title');
      return;
    }
    if (currentReceiverId == null) {
      Get.snackbar('Error', 'No receiver selected');
      return;
    }

    final dt = _combinedDateTime();
    final model = TaskModel(
      id: editingId,
      receiverId: currentReceiverId!,
      title: titleController.text.trim(),
      datetime: dt?.toIso8601String(),
      alarmEnabled: alarmEnabled.value,
    );

    try {
      final res = await supabase.from('tasks').update(model.toMap()).eq('id', editingId!).select().single();
      if (res != null) {
        final updated = TaskModel.fromMap(Map<String, dynamic>.from(res));
        final idx = tasks.indexWhere((e) => e.id == updated.id);
        if (idx != -1) tasks[idx] = updated;
        tasks.assignAll(_sortTasks(tasks));
        clearForm();
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar('Success', 'Task updated');
      }
    } catch (e) {
      debugPrint('confirmEdit error: $e');
      Get.snackbar('Error', 'Failed to update task');
    }
  }

  Future<void> deleteTaskConfirmed(int id) async {
    try {
      await supabase.from('tasks').delete().eq('id', id);
      tasks.removeWhere((t) => t.id == id);
      // close dialog if open
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Deleted', 'Task removed');
    } catch (e) {
      debugPrint('deleteTask error: $e');
      Get.snackbar('Error', 'Failed to delete task');
    }
  }

  // Helpers to manage picked date/time from UI
  void setPickedDate(DateTime d) {
    pickedDate = d;
    // if user picks date but no time yet, keep alarm disabled and hide
    if (pickedTime == null) {
      alarmEnabled.value = false;
    }
  }

  void setPickedTime(TimeOfDay t) {
    pickedTime = t;
  }

  bool showAlarmCheckbox() {
    return pickedDate != null && pickedTime != null;
  }
}
