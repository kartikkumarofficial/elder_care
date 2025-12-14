import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Schedule',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _scheduleBody(),
    );
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

      final now = controller.now.value;

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.timeline.length,
        itemBuilder: (_, i) {
          final item = controller.timeline[i];
          final isPast = item.time.isBefore(now);
          return _timelineTile(item, isPast);
        },
      );
    });
  }

  // ─────────────────────────────────────────────
  // TIMELINE TILE
  // ─────────────────────────────────────────────

  Widget _timelineTile(TimelineItem item, bool isPast) {
    final bg = item.type == TimelineType.event
        ? const Color(0xFFEFF3FF)
        : const Color(0xFFFFF1E6);

    return GestureDetector(
      onTap: () => _openActions(item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${item.time.hour.toString().padLeft(2, '0')}:${item.time.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.nunito(color: Colors.black54),
            ),
          ),
          Column(
            children: [
              Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPast ? kTeal : Colors.white,
                  border: Border.all(color: kTeal, width: 2),
                ),
              ),
              Container(
                height: 70,
                width: 2,
                color: isPast ? kTeal : Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(width: 14),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────

  void _openActions(TimelineItem item) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              item.type == TimelineType.task ? 'Task' : 'Event',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            if (item.type == TimelineType.task)
              ElevatedButton(
                onPressed: () async {
                  await controller.deleteItem(item);
                  await SoundUtils.playDone();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(backgroundColor: kTeal),
                child: const Text('Mark Completed'),
              ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () async {
                await controller.deleteItem(item);
                Get.back();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
