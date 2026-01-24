import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/utils/alarm_service.dart';
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
  RxString repeatType = 'none'.obs;
  RxList<String> repeatDays = <String>[].obs;
  RxBool reminderEnabled = false.obs;
  RxBool isMedicine = false.obs;


  TaskModel? _lastDeletedTask;
  int? _lastDeletedIndex;


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
    editingId = null;
    repeatType.value = 'none';
    repeatDays.clear();
    reminderEnabled.value = false;
    isMedicine.value = false;
  }

  DateTime? _combinedDateTime() {
    if (pickedDate == null && pickedTime == null) return null;

    final d = pickedDate ?? DateTime.now();
    final t = pickedTime ?? const TimeOfDay(hour: 9, minute: 0);

    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }


  /// Sorting: upcoming tasks first , then tasks without datetime.
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
      final da = DateTime.tryParse(a.datetime!)?.toLocal();
      final db = DateTime.tryParse(b.datetime!)?.toLocal();
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });

    return [...withDate, ...withoutDate];
  }

  /// Load tasks for a specific receiver (call from dashboard with receiverId)
  Future<void> loadTasksForReceiver(String receiverId) async {
    currentReceiverId = receiverId;
    debugPrint('🧩 Loading tasks for receiver: $receiverId');
    try {
      final res = await supabase
          .from('tasks')
          .select()
          .eq('receiver_id', receiverId)
          .or('repeat_type.neq.none,is_completed.eq.false')
          .order('datetime', ascending: true);

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
      datetime: dt?.toUtc().toIso8601String(),
      alarmEnabled: reminderEnabled.value,
      vibrate: reminderEnabled.value,
      taskType: isMedicine.value ? 'medicine' : 'normal',
      repeatType: repeatType.value,
      repeatDays: repeatDays,
    );



    try {
      final res = await supabase
          .from('tasks')
          .insert(model.toMap())
          .select()
          .limit(1);

      if (res.isNotEmpty) {
        final created =
        TaskModel.fromMap(Map<String, dynamic>.from(res.first));

        tasks.insert(0, created);
        tasks.assignAll(_sortTasks(tasks));

        try{if (reminderEnabled.value && dt != null) {
          await AlarmService.scheduleWithRepeat(
            baseId: created.id!,
            title: created.title,
            dateTime: dt,
            vibrate: reminderEnabled.value,
            repeatType: repeatType.value,
            repeatDays: repeatDays.toList(),
          );

          await AlarmService.startForegroundService();
          final pending = await AlarmService.debugPendingNotifications();
          debugPrint('Pending alarms: ${pending.length}');
        }}catch(e){
          debugPrint('Alarm failed: $e');
        }

        clearForm();
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar('Success', 'Task added');
      }

    } catch (e) {
      debugPrint('addTask error: $e');
      Get.snackbar('Failed to add task', e.toString());
    }
  }

  Future<void> startEdit(TaskModel t) async {
    editingId = t.id;
    titleController.text = t.title;

    repeatType.value = t.repeatType;
    repeatDays.assignAll(t.repeatDays);
    reminderEnabled.value = t.alarmEnabled;
    isMedicine.value = t.taskType == 'medicine';

    if (t.datetime != null) {
      try {
        final dt = DateTime.parse(t.datetime!).toLocal();
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
      datetime: dt?.toUtc().toIso8601String(),

      alarmEnabled: reminderEnabled.value,
      vibrate: reminderEnabled.value,
      taskType: isMedicine.value ? 'medicine' : 'normal',
      repeatType: repeatType.value,
      repeatDays: repeatDays,
    );

    try {
      final res = await supabase
          .from('tasks')
          .update(model.toUpdateMap())
          .eq('id', editingId!)
          .select()
          .limit(1);

      if (res.isNotEmpty) {
        final updated =
        TaskModel.fromMap(Map<String, dynamic>.from(res.first));

        final idx = tasks.indexWhere((e) => e.id == updated.id);
        if (idx != -1) tasks[idx] = updated;
        tasks.assignAll(_sortTasks(tasks));

        await AlarmService.cancel(updated.id!);

        if (reminderEnabled.value && dt != null) {
          await AlarmService.scheduleWithRepeat(
            baseId: updated.id!,
            title: updated.title,
            dateTime: dt,
            vibrate: reminderEnabled.value,
            repeatType: repeatType.value,
            repeatDays: repeatDays.toList(),
          );

        }

        await AlarmService.startForegroundService();
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
      await AlarmService.cancel(id);

      // Checking if any alarms still exist
      final hasAnyAlarm =
      tasks.any((t) => t.alarmEnabled && t.datetime != null);

      if (!hasAnyAlarm) {
        await AlarmService.stopForegroundService();
      }

      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Deleted', 'Task removed');
    } catch (e) {
      debugPrint('deleteTask error: $e');
      Get.snackbar('Error', 'Failed to delete task');
    }
  }




  Future<void> deleteTaskWithUndo(TaskModel task, int index) async {
    _lastDeletedTask = task;
    _lastDeletedIndex = index;

    // Remove from UI immediately
    tasks.removeAt(index);

    // Cancel alarm immediately
    if (task.alarmEnabled && task.datetime != null) {
      await AlarmService.cancel(task.id!);
    }

    // Delete from DB
    await supabase.from('tasks').delete().eq('id', task.id!);

    // Snackbar with UNDO
    Get.snackbar(
      'Task completed',
      task.title,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: Get.height*0.03),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: undoDelete,
        child: const Text('UNDO', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black87.withAlpha(90),
      colorText: Colors.white,
    );
  }

  Future<void> undoDelete() async {
    if (_lastDeletedTask == null || _lastDeletedIndex == null) return;

    Get.back(); // dismiss snackbar

    final restored = _lastDeletedTask!;

    final map = restored.toMap();
    map.remove('id');

    final res = await supabase
        .from('tasks')
        .insert(map)
        .select()
        .limit(1);

    if (res.isNotEmpty) {
      final recreated = TaskModel.fromMap(res.first);
      tasks.insert(_lastDeletedIndex!, recreated);

      if (recreated.alarmEnabled && recreated.datetime != null) {
        final dt = DateTime.parse(recreated.datetime!).toLocal();
        await AlarmService.scheduleWithRepeat(
          baseId: recreated.id!,
          title: recreated.title,
          dateTime: dt,
          vibrate: true,
          repeatType: recreated.repeatType,
          repeatDays: recreated.repeatDays,
        );
      }
    }

    _lastDeletedTask = null;
    _lastDeletedIndex = null;
  }

  Future<void> markTaskCompleted(TaskModel task, int index) async {
    tasks.removeAt(index);

    if (task.alarmEnabled && task.datetime != null) {
      await AlarmService.cancel(task.id!);
    }


    await supabase
        .from('tasks')
        .update({'is_completed': true})
        .eq('id', task.id!);

    Get.snackbar(
      'Task completed',
      task.title,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }






  // Helpers to manage picked date/time from UI
  void setPickedDate(DateTime d) {
    pickedDate = d;
  }

  void setPickedTime(TimeOfDay t) {
    pickedTime = t;

    // time first → auto set date to today
    pickedDate ??= DateTime.now();

    if (!isMedicine.value && !reminderEnabled.value) {
      reminderEnabled.value = true;
    }
  }


  bool showAlarmCheckbox() {
    return pickedDate != null && pickedTime != null;
  }
}
