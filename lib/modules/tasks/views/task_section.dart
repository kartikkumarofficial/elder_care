
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import '../../../app/utils/sound_utils.dart';
import '../controllers/task_controller.dart';
import '../../../core/models/task_model.dart';
import '../../dashboard/controllers/nav_controller.dart';
import '../widgets/add_edit_dialog.dart';
import '../widgets/day_chips.dart';
import '../widgets/repeat_options_tile.dart';
import '../widgets/task_tile.dart';
import '../widgets/tasks_details_dialog.dart';

const Color kTeal = Color(0xFF7AB7A7);

class TaskSection extends StatelessWidget {
  final String? receiverIdOverride;

  TaskSection({Key? key, this.receiverIdOverride}) : super(key: key);

  // final TaskController controller = Get.find<TaskController>();
  final TaskController controller = Get.put(TaskController(),permanent: true);
  final NavController nav = Get.find<NavController>();

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rid = receiverIdOverride ?? nav.linkedReceiverId.value;
      if (rid.isNotEmpty && controller.currentReceiverId != rid) {
        controller.loadTasksForReceiver(rid);
      }
    });



    // Load initial tasks if id already present
    final initialId = receiverIdOverride ?? nav.linkedReceiverId.value;
    if (initialId.isNotEmpty) {
      controller.loadTasksForReceiver(initialId);
    }


    final receiverId = receiverIdOverride?.isNotEmpty == true
        ? receiverIdOverride!
        : nav.linkedReceiverId.value;

    if (receiverId.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          receiverIdOverride != null ? "No tasks available" : "No receiver linked yet",
          style: GoogleFonts.nunito(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return _buildTaskUI(context);

  }

  Widget _buildTaskUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tasks',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.clearForm();
                  _openAddDialog(context, isEdit: false);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: kTeal,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: kTeal.withOpacity(0.22),
                          blurRadius: 8,
                          offset: Offset(0, 5))
                    ],
                  ),
                  child: Row(children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Add',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              )
            ],
          ),

          SizedBox(height:Get.height*0.018 ),

          // TASK LIST
          Obx(() {
            final list = controller.tasks;

            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text('No tasks yet',
                    style: GoogleFonts.nunito(color: Colors.grey)),
              );
            }

            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: list.length,
                separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final isRemoving = false.obs;

                    final t = list[i];


                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        padding: const EdgeInsets.only(left: 24),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: kTeal.withAlpha(60),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),

                      // Swipe RIGHT → LEFT
                      secondaryBackground: Container(
                        padding: const EdgeInsets.only(right: 24),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: kTeal.withAlpha(60),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),

                      onDismissed: (_) {
                        controller.deleteTaskWithUndo(t, i);
                      },

                      child: Obx(() {
                        return Stack(
                          alignment: Alignment.center,
                          children: [

                            Container(
                              height: Get.height*0.1,
                              decoration: BoxDecoration(
                                color: kTeal.withAlpha(60),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 24),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 28,
                              ),
                            ),

                            // Foreground task tile
                            AnimatedSlide(
                              offset: isRemoving.value ? const Offset(-1.2, 0) : Offset.zero,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                              child: AnimatedOpacity(
                                opacity: isRemoving.value ? 0 : 1,
                                duration: const Duration(milliseconds: 400),
                                child: GestureDetector(
                                  onTap: () => _openDetailsDialog(context, t),
                                  onLongPress: () => _openDetailsDialog(context, t),
                                  child: TaskTile(
                                    task: t,
                                    onDone: () async {
                                      await SoundUtils.playDone();
                                      HapticFeedback.mediumImpact();

                                      isRemoving.value = true;
                                      await Future.delayed(const Duration(milliseconds: 600));

                                      controller.markTaskCompleted(t, i);
                                    },

                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                    );

                  }

              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _dismissBgLeft() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(left: 24),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
  );

  Widget _dismissBgRight() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
  );





  void _openAddDialog(BuildContext ctx, {required bool isEdit}) {
    showDialog(
        context: ctx,
        builder: (_) =>
            AddEditTaskDialog(isEdit: isEdit, controller: controller));
  }

  void _openDetailsDialog(BuildContext context, TaskModel t) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.25),
        pageBuilder: (_, __, ___) {
          return TaskDetailsDialog(
            task: t,
            controller: controller,
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
  void openCustomDialog(BuildContext context, Widget dialog) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.25),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => dialog,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }


}












