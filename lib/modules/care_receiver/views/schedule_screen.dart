import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/utils/sound_utils.dart';
import '../../dashboard/controllers/nav_controller.dart';
import '../controllers/schedule_controller.dart';
import '../../../core/models/timeline_item.dart';

const Color kTeal = Color(0xFF7AB7A7);

class ScheduleScreen extends StatefulWidget {
  /// If provided → care receiver view
  /// If null → caregiver view
  final String? receiverIdOverride;

  const ScheduleScreen({Key? key, this.receiverIdOverride}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final NavController nav = Get.find<NavController>();
  final ScheduleController controller = Get.find<ScheduleController>();

  Worker? _receiverWorker;

  @override
  void initState() {
    super.initState();

    final id = widget.receiverIdOverride ?? nav.linkedReceiverId.value;

    if (id.isNotEmpty) {
      controller.loadForReceiver(id, DateTime.now());
    }

    /// Listen only for caregiver flow
    if (widget.receiverIdOverride == null) {
      _receiverWorker = ever<String>(
        nav.linkedReceiverId,
            (rid) {
          if (rid.isNotEmpty) {
            controller.loadForReceiver(rid, DateTime.now());
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _receiverWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveReceiverId =
        widget.receiverIdOverride ?? nav.linkedReceiverId.value;

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

      /// 🚫 NO Obx HERE
      body: effectiveReceiverId.isEmpty
          ? _noReceiverView()
          : _scheduleBody(),
    );
  }

  // ─────────────────────────────────────────────
  // BODY (reactive parts only)
  // ─────────────────────────────────────────────

  Widget _scheduleBody() {
    return Obx(() {
      final isLoading = controller.loading.value;
      final timeline = controller.timeline;
      final now = controller.now.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (timeline.isEmpty) {
        return Center(
          child: Text(
            'No tasks or events today',
            style: GoogleFonts.nunito(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: timeline.length,
        itemBuilder: (_, i) {
          final item = timeline[i];
          final isPast = item.time.isBefore(now);
          return _timelineTile(item, isPast);
        },
      );
    });
  }

  Widget _noReceiverView() {
    return Center(
      child: Text(
        'No care receiver linked',
        style: GoogleFonts.nunito(color: Colors.grey),
      ),
    );
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
