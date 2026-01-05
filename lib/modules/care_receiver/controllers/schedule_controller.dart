import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/timeline_item.dart';

class ScheduleController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<TimelineItem> timeline = <TimelineItem>[].obs;
  final RxBool loading = false.obs;
  final selectedDate = DateTime.now().obs;

  // ─────────────────────────────────────────────
  // PROGRESS
  // ─────────────────────────────────────────────

  int get totalCount =>
      timeline.where((e) => e.type == TimelineType.task).length;

  int get completedCount =>
      timeline.where(
            (e) => e.type == TimelineType.task && e.isCompleted,
      ).length;

  // ─────────────────────────────────────────────
  // LOAD DATA
  // ─────────────────────────────────────────────

  Future<void> loadForCurrentUser(DateTime day) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    loading.value = true;
    timeline.clear();

    try {
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // ───── TASKS (no date filter because of repeats)
      final taskRes = await supabase
          .from('tasks')
          .select()
          .eq('receiver_id', user.id);

      final taskItems = (taskRes as List)
          .map((e) => TaskModel.fromMap(e))
          .where((task) => task.datetime != null)
          .where((task) => _shouldAppear(task, day))
          .map((task) => TimelineItem(
        type: TimelineType.task,
        id: task.id!,
        title: task.title,
        time: DateTime.parse(task.datetime!).toLocal(),
        alarmEnabled: task.alarmEnabled,
        isCompleted: task.isCompleted,
      ))
          .toList();

      // ───── EVENTS (using created_at as fallback)
      final eventRes = await supabase
          .from('events')
          .select()
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      final eventItems = (eventRes as List)
          .map((e) => TimelineItem(
        type: TimelineType.event,
        id: e['id'],
        title: e['title'] ?? '',
        time: DateTime.parse(e['created_at']).toLocal(),
      ))
          .toList();

      timeline.assignAll(
        [...taskItems, ...eventItems]
          ..sort((a, b) => a.time.compareTo(b.time)),
      );
    } catch (e) {
      print('❌ Schedule load error: $e');
    } finally {
      loading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // VISIBILITY LOGIC (CRITICAL FIX)
  // ─────────────────────────────────────────────

  bool _shouldAppear(TaskModel task, DateTime day) {
    if (task.datetime == null) return false;

    final taskStartDateTime =
    DateTime.parse(task.datetime!).toLocal();

    final taskStartDate = DateTime(
      taskStartDateTime.year,
      taskStartDateTime.month,
      taskStartDateTime.day,
    );

    final targetDate = DateTime(
      day.year,
      day.month,
      day.day,
    );

    // ❌ Never show before task start date
    if (targetDate.isBefore(taskStartDate)) return false;

    switch (task.repeatType) {
      case 'tomorrow':
        final tomorrow = taskStartDate.add(const Duration(days: 1));
        return _sameDay(tomorrow, targetDate);

      case 'daily':
        return true;

      case 'weekly':
        return taskStartDate.weekday == targetDate.weekday;

      case 'custom':
        return task.repeatDays
            .contains(_weekday(targetDate.weekday));

      case 'none':
      default:
        return _sameDay(taskStartDate, targetDate);
    }

  }

  String _weekday(int d) =>
      ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][d - 1];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ─────────────────────────────────────────────
  // COMPLETE TASK
  // ─────────────────────────────────────────────

  Future<void> markTaskCompleted(TimelineItem item) async {
    await supabase
        .from('tasks')
        .update({'is_completed': true})
        .eq('id', item.id);

    final index = timeline.indexOf(item);
    timeline[index] =
        timeline[index].copyWith(isCompleted: true);
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  Future<void> deleteItem(TimelineItem item) async {
    final table =
    item.type == TimelineType.task ? 'tasks' : 'events';

    await supabase.from(table).delete().eq('id', item.id);
    timeline.remove(item);
  }
}
