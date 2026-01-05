import 'package:elder_care/modules/tasks/controllers/task_controller.dart';
import 'package:elder_care/modules/tasks/views/task_section.dart' hide kTeal;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../app/utils/sound_utils.dart';
import '../../../core/models/timeline_item.dart';
import '../../events/controllers/events_controller.dart';
import '../controllers/schedule_controller.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleController controller = Get.find<ScheduleController>();

  @override
  void initState() {
    super.initState();
    controller.loadForCurrentUser(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return  Obx(() {
        return Column(
          children: [
            scheduleHeader(
              completed: controller.completedCount,
              total: controller.totalCount,
            ),
            const SizedBox(height: 16),
            dateSelector(controller),
            const SizedBox(height: 12),
            Expanded(child: _scheduleBody()),
          ],
        );
      });
  }

  // ─────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────

  Widget _scheduleBody() {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.timeline.isEmpty) {
        return Center(
          child: Text(
            'No tasks or events today',
            style: GoogleFonts.nunito(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.timeline.length,
        itemBuilder: (_, i) {
          final item = controller.timeline[i];
          return _timelineTile(item);
        },
      );
    });
  }


  // TIMELINE TILE


  Widget _timelineTile(TimelineItem item) {
    final isTask = item.type == TimelineType.task;
    final isCompleted = isTask && item.isCompleted;

    final bg = item.type == TimelineType.event
        ? const Color(0xFFEFF3FF)
        : const Color(0xFFFFF1E6);

    return GestureDetector(
      onTap: () => _openActions(item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TIME
          SizedBox(
            width: 60,
            child: Text(
              DateFormat.jm().format(item.time),
              style: GoogleFonts.nunito(color: Colors.black54),
            ),
          ),

          /// DOT + LINE
          Column(
            children: [
              Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? kTeal : Colors.white,
                  border: Border.all(color: kTeal, width: 2),
                ),
              ),
              Container(
                height: 70,
                width: 2,
                color: isCompleted ? kTeal : Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(width: 14),

          /// CARD
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                item.title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration:
                  isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ACTION DIALOG


  void _openActions(TimelineItem item) {
    final isTask = item.type == TimelineType.task;
    final isCompleted = isTask && item.isCompleted;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF4F2), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isTask ? 'Task' : 'Event',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),

              /// MARK COMPLETED
              if (isTask && !isCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.markTaskCompleted(item);
                      await SoundUtils.playDone();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTeal,
                      elevation: 0,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Mark Completed',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              if (isTask && !isCompleted) const SizedBox(height: 10),

              /// DELETE
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await controller.deleteItem(item);
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side:
                    BorderSide(color: Colors.red.withOpacity(0.6)),
                  ),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunito(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// ________________________________________



  Widget scheduleHeader({
    required int completed,
    required int total,
  }) {
    final percent = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFEAF4F2),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Schedule",
                  style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You are almost done!",
                  style: GoogleFonts.nunito(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "$completed / $total tasks completed",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // RIGHT (CIRCULAR PROGRESS)
          SizedBox(
            height: 90,
            width: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 8,
                  backgroundColor: Colors.white,
                  color: kTeal,
                ),
                Text(
                  "${(percent * 100).round()}%",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget dateSelector(ScheduleController controller) {

    final today = DateTime.now();


    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (_, i) {
          final date = today.add(Duration(days: i));
          final isSelected =
              controller.selectedDate.value.day == date.day;

          return GestureDetector(
            onTap: () {
              controller.selectedDate.value = date;
              controller.loadForCurrentUser(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? kTeal : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kTeal),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E().format(date),
                    style: GoogleFonts.nunito(
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

