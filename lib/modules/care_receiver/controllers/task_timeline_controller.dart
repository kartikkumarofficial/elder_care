// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import '../../../core/models/task_model.dart';
// import '../../../core/models/event_model.dart';
// import '../../../core/models/timeline_item.dart';
// import '../../../core/models/timeline_item.dart';
//
// class ScheduleTimelineController extends GetxController {
//   final SupabaseClient supabase = Supabase.instance.client;
//
//   RxList<TimelineItem> timeline = <TimelineItem>[].obs;
//   RxBool loading = false.obs;
//
//   Rx<DateTime> now = DateTime.now().o bs;
//   Timer? _clock;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _clock = Timer.periodic(const Duration(minutes: 1), (_) {
//       now.value = DateTime.now();
//     });
//   }
//
//   @override
//   void onClose() {
//     _clock?.cancel();
//     super.onClose();
//   }
//
//   Future<void> loadForReceiver(String receiverId, DateTime day) async {
//     loading.value = true;
//
//     final start = DateTime(day.year, day.month, day.day);
//     final end = start.add(const Duration(days: 1));
//
//     /// ---------- TASKS ----------
//     final taskRes = await supabase
//         .from('tasks')
//         .select()
//         .eq('receiver_id', receiverId)
//         .gte('datetime', start.toIso8601String())
//         .lt('datetime', end.toIso8601String())
//         .order('datetime');
//
//     final tasks = (taskRes as List)
//         .map((e) => TaskModel.fromJson(e))
//         .map((t) => TimelineItem(
//       type: TimelineType.task,
//       id: t.id!,
//       title: t.title,
//       time: DateTime.parse(t.datetime!).toLocal(),
//       alarmEnabled: t.alarmEnabled,
//     ))
//         .toList();
//
//     /// ---------- EVENTS ----------
//     final eventRes = await supabase
//         .from('events')
//         .select()
//         .gte('created_at', start.toIso8601String())
//         .lt('created_at', end.toIso8601String());
//
//     final events = (eventRes as List)
//         .map((e) => EventModel.fromJson(e))
//         .map((e) => TimelineItem(
//       type: TimelineType.event,
//       id: e.id,
//       title: e.title,
//       time: DateTime.parse(e.date),
//       category: e.category,
//       notes: e.notes,
//     ))
//         .toList();
//
//     /// ---------- MERGE ----------
//     final merged = [...tasks, ...events]
//       ..sort((a, b) => a.time.compareTo(b.time));
//
//     timeline.assignAll(merged);
//     loading.value = false;
//   }
// }
