import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/task_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/models/timeline_item.dart';

class ScheduleController extends GetxController {
  final supabase = Supabase.instance.client;

  final RxList<TimelineItem> timeline = <TimelineItem>[].obs;
  final RxBool loading = false.obs;

  final Rx<DateTime> now = DateTime.now().obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      now.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // LOAD DATA
  // ─────────────────────────────────────────────

  Future<void> loadForReceiver(String receiverId, DateTime day) async {

    debugPrint("📅 Loading schedule for receiver: $receiverId");
    loading.value = true;

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    /// TASKS
    final taskRes = await supabase
        .from('tasks')
        .select()
        .eq('receiver_id', receiverId)
        .gte('datetime', start.toIso8601String())
        .lt('datetime', end.toIso8601String())
        .order('datetime');

    final taskItems = (taskRes as List)
        .map((e) => TaskModel.fromMap(e))
        .where((t) => t.datetime != null)
        .map((t) => TimelineItem(
      type: TimelineType.task,
      id: t.id!,
      title: t.title,
      time: DateTime.parse(t.datetime!).toLocal(),
      alarmEnabled: t.alarmEnabled,
    ))
        .toList();

    /// EVENTS
    final eventRes = await supabase
        .from('events')
        .select()
        .gte('created_at', start.toIso8601String())
        .lt('created_at', end.toIso8601String());

    final eventItems = (eventRes as List)
        .map((e) => EventModel.fromMap(e))
        .map((e) => TimelineItem(
      type: TimelineType.event,
      id: e.id!,
      title: e.title,
      time: DateTime.parse(e.datetime).toLocal(),
      category: e.category,
      notes: e.notes,
    ))
        .toList();

    timeline.assignAll(
      [...taskItems, ...eventItems]
        ..sort((a, b) => a.time.compareTo(b.time)),
    );

    loading.value = false;
  }

  // ─────────────────────────────────────────────
  // DELETE (TASK OR EVENT)
  // ─────────────────────────────────────────────

  Future<void> deleteItem(TimelineItem item) async {
    final table = item.type == TimelineType.task ? 'tasks' : 'events';
    await supabase.from(table).delete().eq('id', item.id);
    timeline.remove(item);
  }


  Future<void> loadForCurrentUser(DateTime day) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await loadForReceiver(user.id, day);
  }

}
