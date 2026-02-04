  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:intl/intl.dart';

  import '../../../app/utils/sound_utils.dart';
  import '../../../core/models/timeline_item.dart';
  import '../controllers/schedule_controller.dart';
  import '../widgets/animated_ring_progress.dart';

  const Color kTeal = Color(0xFF7AB7A7);
  final w = Get.width;
  final h = Get.height;

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
      return RefreshIndicator(
        onRefresh: ()async {
          await controller.loadForCurrentUser(
            controller.selectedDate.value,
          );
        }  ,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              ///  BACKGROUND
              Positioned.fill(
                child: Image.asset(
                  'assets/images/schedule.png',
                  fit: BoxFit.cover,
                ),
              ),

              ///  OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF6FAF9),
                        Color(0xFFFDFBF8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              /// CONTENT
              Obx(() {
                return Column(
                  children: [
                    _scheduleHeader(),
                    const SizedBox(height: 12),
                    _dateSelector(),
                    const SizedBox(height: 8),
                    Expanded(child: _scheduleBody()),
                    SizedBox(height: Get.height*0.05,),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    }

    
    // HEADER
    

    Widget _scheduleHeader() {
      final completed = controller.completedCount;
      final total = controller.totalCount;
      final percent = total == 0 ? 0.0 : completed / total;

      return Container(
        padding: EdgeInsets.fromLTRB(
          w * 0.05,
          h * 0.035,
          w * 0.05,
          h * 0.028,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFEAF4F2),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Get.height*0.02,),
                  Text(
                    "Schedule",
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.065,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: h * 0.008),
                  Text(
                    "$completed / $total completed",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: Get.height*0.01,),
                ],
              ),
            ),

            Column(
              children: [
                SizedBox(height:Get.height*0.02),
                AnimatedRingProgress(
                  value: percent,
                  color: kTeal,
                ),
              ],
            ),

          ],
        ),
      );
    }

    // DATE SELECTOR


    Widget _dateSelector() {
      final today = DateTime.now();

      return SizedBox(
        height: h * 0.105,
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
                width: w*0.15,
                  margin: EdgeInsets.only(right: w * 0.03),
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
                        color:
                        isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: GoogleFonts.nunito(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.bold,
                        color:
                        isSelected ? Colors.white : Colors.black,
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

    
    // BODY
    

    Widget _scheduleBody() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.timeline.isEmpty) {
        return Center(
          child: Text(
            'Nothing planned today 🌱',
            style: GoogleFonts.nunito(color: Colors.black54),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          w * 0.05,
          h * 0.012,
          w * 0.05,
          h * 0.04,
        ),
        itemCount: controller.timeline.length,
        itemBuilder: (_, i) {
          final item = controller.timeline[i];
          final isLast = i == controller.timeline.length - 1;
          final isFirst = i == 0;
          return _timelineTile(item, isLast, isFirst);

        },
      );
    }

    
    // TIMELINE TILE


    Widget _timelineTile(TimelineItem item, bool isLast, bool isFirst)
   {
      final isTask = item.type == TimelineType.task;
      final isCompleted = isTask && item.isCompleted;

      final now = DateTime.now();
      final selectedDate = controller.selectedDate.value;

      final isToday =
          selectedDate.year == now.year &&
              selectedDate.month == now.month &&
              selectedDate.day == now.day;

      final isPast = isToday && item.time.isBefore(now);


      final bg = isCompleted
          ? kTeal.withAlpha(36)
          : item.type == TimelineType.event
          ? const Color(0xFFEFF3FF)
          : const Color(0xFFFFF1E6);


      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TIME
          SizedBox(
            width: Get.width*0.18,
            child: Padding(
              padding:  EdgeInsets.only(top: h * 0.028),
              child: Text(
                DateFormat.jm().format(item.time),
                style: GoogleFonts.nunito(color: Colors.black54,fontSize:  w * 0.035,),
              ),
            ),
          ),


          Column(
            children: [
              // top line

              Container(
                height: h * 0.028,
                width: 2,
                color: isPast ? kTeal : Colors.grey.shade300,
              ),

              // dot
              Container(
                height: w * 0.045,
                width: w * 0.045,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? kTeal
                      : (isPast ? kTeal : Colors.white),
                  border: Border.all(color: kTeal, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),

              // bottom line
              if (!isLast)
                Container(
                  height: h * 0.06,
                  width: 2,
                  color: isPast ? kTeal : Colors.grey.shade300,
                ),
            ],
          ),


          SizedBox(width: w*0.035),

          /// CARD

            Expanded(
              child: GestureDetector(
                onTap: () => _openActions(item),
                child: Container(

                  margin: EdgeInsets.only(bottom: h * 0.02,top: h*0.01),
                  padding:  EdgeInsets.all(w*0.04),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? kTeal : Colors.black87,
                    ),



                ),
              ),
            ),
          ),
        ],
      );
    }




    // ACTIONS
    void _openActions(TimelineItem item) {
      final isTask = item.type == TimelineType.task;
      final isCompleted = isTask && item.isCompleted;

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 20),

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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Mark Completed',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () async {
                    await controller.deleteItem(item);
                    Get.back();
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
