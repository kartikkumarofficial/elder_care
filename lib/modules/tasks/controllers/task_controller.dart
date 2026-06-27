import 'package:elder_care/core/services/reciever_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/task_model.dart';
import '../../../core/services/native_alarm_service.dart';
import '../../../core/services/fcm_service.dart';

class TaskController extends GetxController {
  final supabase = Supabase.instance.client;

  RxList<TaskModel> tasks = <TaskModel>[].obs;

  final titleController = TextEditingController();
  final dateController = TextEditingController();
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

  bool showAlarmCheckbox() {
    return pickedDate != null && pickedTime != null;
  }

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

  Future<void> loadTasksForReceiver(String receiverId) async {
    currentReceiverId = receiverId;
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
    }
  }

  Future<void> addTask() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Enter task title');
      return;
    }
    if (currentReceiverId == null) return;

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
      final res = await supabase.from('tasks').insert(model.toMap()).select().limit(1);

      if (res.isNotEmpty) {
        final created = TaskModel.fromMap(Map<String, dynamic>.from(res.first));
        tasks.insert(0, created);
        tasks.assignAll(_sortTasks(tasks));

        final myUid = supabase.auth.currentUser?.id;
        final isReceiver = myUid == currentReceiverId;

        if (reminderEnabled.value && dt != null) {
          if (isReceiver) {
            await NativeAlarmService.schedule(
              alarmId: created.id.toString(),
              dateTime: dt,
              title: created.title,
            );
          } else {
            await FcmService.sendRemoteAlarm(
              receiverId: currentReceiverId!,
              alarmId: created.id.toString(),
              time: dt,
              title: created.title,
            );
          }
        }

        if (isReceiver) {
          final caregiverId = await ReceiverService.getLinkedCaregiverId();
          if (caregiverId != null) {
            await FcmService.sendNotification(
              receiverId: caregiverId,
              title: "Task Added by Receiver",
              body: "New task: ${created.title}",
              type: "task_added"
            );
          }
        } else {
          await FcmService.sendNotification(
            receiverId: currentReceiverId!,
            title: "New Task for You",
            body: "Your caregiver added: ${created.title}",
            type: "task_added"
          );
        }

        clearForm();
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar('Success', 'Task added');
      }
    } catch (e) {
      debugPrint('addTask error: $e');
    }
  }

  Future<void> confirmEdit() async {
    if (editingId == null || currentReceiverId == null) return;
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Enter task title');
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
      final res = await supabase.from('tasks').update(model.toUpdateMap()).eq('id', editingId!).select().limit(1);

      if (res.isNotEmpty) {
        final updated = TaskModel.fromMap(Map<String, dynamic>.from(res.first));
        final idx = tasks.indexWhere((e) => e.id == updated.id);
        if (idx != -1) tasks[idx] = updated;
        tasks.assignAll(_sortTasks(tasks));

        final myUid = supabase.auth.currentUser?.id;
        final isReceiver = myUid == currentReceiverId;

        if (isReceiver) {
          await NativeAlarmService.cancel(updated.id.toString());
        } else {
          await FcmService.sendRemoteAlarm(
            receiverId: currentReceiverId!,
            alarmId: updated.id.toString(),
            time: DateTime.now(),
            title: "",
            isCancel: true,
          );
        }

        if (reminderEnabled.value && dt != null) {
          if (isReceiver) {
            await NativeAlarmService.schedule(
              alarmId: updated.id.toString(),
              dateTime: dt,
              title: updated.title,
            );
          } else {
            await FcmService.sendRemoteAlarm(
              receiverId: currentReceiverId!,
              alarmId: updated.id.toString(),
              time: dt,
              title: updated.title,
            );
          }
        }

        clearForm();
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar('Success', 'Task updated');
      }
    } catch (e) {
      debugPrint('confirmEdit error: $e');
    }
  }

  Future<void> deleteTaskConfirmed(int id) async {
    try {
      await supabase.from('tasks').delete().eq('id', id);
      tasks.removeWhere((t) => t.id == id);

      final myUid = supabase.auth.currentUser?.id;
      final isReceiver = myUid == currentReceiverId;

      if (isReceiver) {
        await NativeAlarmService.cancel(id.toString());
        final caregiverId = await ReceiverService.getLinkedCaregiverId();
        if (caregiverId != null) {
          await FcmService.sendNotification(
            receiverId: caregiverId,
            title: "Task Deleted",
            body: "Receiver removed a task",
            type: "task_deleted"
          );
        }
      } else if (currentReceiverId != null) {
         await FcmService.sendRemoteAlarm(
          receiverId: currentReceiverId!,
          alarmId: id.toString(),
          time: DateTime.now(),
          title: "",
          isCancel: true,
        );
         await FcmService.sendNotification(
            receiverId: currentReceiverId!,
            title: "Task Cancelled",
            body: "Caregiver removed a task",
            type: "task_deleted"
          );
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

    tasks.removeAt(index);

    final myUid = supabase.auth.currentUser?.id;
    final isReceiver = myUid == currentReceiverId;

    if (isReceiver) {
      await NativeAlarmService.cancel(task.id!.toString());
    } else if (currentReceiverId != null) {
      await FcmService.sendRemoteAlarm(
        receiverId: currentReceiverId!,
        alarmId: task.id.toString(),
        time: DateTime.now(),
        title: "",
        isCancel: true,
      );
    }

    await supabase.from('tasks').delete().eq('id', task.id!);

    if (isReceiver) {
      final caregiverId = await ReceiverService.getLinkedCaregiverId();
      if (caregiverId != null) {
        await FcmService.sendNotification(
          receiverId: caregiverId,
          title: "Task Deleted",
          body: "Receiver removed: ${task.title}",
          type: "task_deleted"
        );
      }
    }

    Get.snackbar(
      'Task deleted',
      task.title,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: undoDelete,
        child: const Text('UNDO', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }

  Future<void> undoDelete() async {
    if (_lastDeletedTask == null || _lastDeletedIndex == null) return;
    Get.back();

    final restored = _lastDeletedTask!;
    final map = restored.toMap()..remove('id');

    try {
      final res = await supabase.from('tasks').insert(map).select().limit(1);
      if (res.isNotEmpty) {
        final recreated = TaskModel.fromMap(res.first);
        tasks.insert(_lastDeletedIndex!, recreated);
        tasks.assignAll(_sortTasks(tasks));

        if (recreated.alarmEnabled && recreated.datetime != null) {
          final dt = DateTime.parse(recreated.datetime!).toLocal();
          final isReceiver = supabase.auth.currentUser?.id == currentReceiverId;
          
          if (isReceiver) {
            await NativeAlarmService.schedule(
              alarmId: recreated.id.toString(),
              dateTime: dt,
              title: recreated.title,
            );
          } else {
            await FcmService.sendRemoteAlarm(
              receiverId: currentReceiverId!,
              alarmId: recreated.id.toString(),
              time: dt,
              title: recreated.title,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('undoDelete error: $e');
    }

    _lastDeletedTask = null;
    _lastDeletedIndex = null;
  }

  Future<void> markTaskCompleted(TaskModel task, int index) async {
    tasks.removeAt(index);

    final myUid = supabase.auth.currentUser?.id;
    final isReceiver = myUid == currentReceiverId;

    if (isReceiver) {
      await NativeAlarmService.cancel(task.id!.toString());
    } else if (currentReceiverId != null) {
       await FcmService.sendRemoteAlarm(
         receiverId: currentReceiverId!,
         alarmId: task.id.toString(),
         time: DateTime.now(),
         title: "",
         isCancel: true,
       );
    }

    await supabase.from('tasks').update({'is_completed': true}).eq('id', task.id!);

    if (isReceiver) {
      final caregiverId = await ReceiverService.getLinkedCaregiverId();
      if (caregiverId != null) {
        await FcmService.sendNotification(
          receiverId: caregiverId,
          title: "Task Completed",
          body: "Receiver completed: ${task.title}",
          type: "task_completed"
        );
      }
    }

    Get.snackbar('Task completed', task.title, snackPosition: SnackPosition.BOTTOM);
  }

  void startEdit(TaskModel t) {
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

  void setPickedDate(DateTime d) { pickedDate = d; }
  void setPickedTime(TimeOfDay t) {
    pickedTime = t;
    pickedDate ??= DateTime.now();
    if (!isMedicine.value && !reminderEnabled.value) {
      reminderEnabled.value = true;
    }
  }
}
