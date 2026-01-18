
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
import '../widgets/day_chips.dart';
import '../widgets/repeat_card.dart';
import '../widgets/task_tile.dart';

const Color kTeal = Color(0xFF7AB7A7);

class TaskSection extends StatelessWidget {
  final String? receiverIdOverride;

  TaskSection({Key? key, this.receiverIdOverride}) : super(key: key);

  final TaskController controller = Get.put(TaskController());
  final NavController nav = Get.find<NavController>();

  @override
  Widget build(BuildContext context) {
    // 🔥 Reactively reload tasks whenever linkedReceiverId changes
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

                      // Swipe LEFT → RIGHT
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
                                      controller.deleteTaskWithUndo(t, i);
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

  void _openDetailsDialog(BuildContext ctx, TaskModel t) {
    showDialog(
        context: ctx,
        builder: (_) => TaskDetailsDialog(task: t, controller: controller));
  }
}


/// Details dialog (tap)
class TaskDetailsDialog extends StatelessWidget {
  final TaskModel task;
  final TaskController controller;
  const TaskDetailsDialog({Key? key, required this.task, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime? dt;
    try {
      if (task.datetime != null) dt = DateTime.parse(task.datetime!).toLocal();
    } catch (_) {}

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// NEW TITLE HEADING
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Task",
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              /// Task Name
              Text(
                task.title,
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 8),

              if (dt != null)
                Text(
                  '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.nunito(color: Colors.black54),
                ),

              SizedBox(height: 18),

              Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.startEdit(task);
                  Navigator.pop(context);
                  showDialog(context: context, builder: (_) => AddEditTaskDialog(isEdit: true, controller: controller));
                },
                style: ElevatedButton.styleFrom(backgroundColor: kTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Edit', style: GoogleFonts.nunito(color: Colors.white)),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.deleteTaskConfirmed(task.id!);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Delete', style: GoogleFonts.nunito(color: Colors.white)),
              ),
            ),
          ])
        ]),
      ),
    );
  }
}

/// Edit/Delete quick dialog (long press)
class _EditDeleteDialog extends StatelessWidget {
  final TaskModel task;
  final TaskController controller;
  const _EditDeleteDialog({Key? key, required this.task, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Manage Task', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.startEdit(task);
              showDialog(context: context, builder: (_) => AddEditTaskDialog(isEdit: true, controller: controller));
            },
            style: ElevatedButton.styleFrom(backgroundColor: kTeal),
            child: Text('Edit', style: GoogleFonts.nunito(color: Colors.white)),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              controller.deleteTaskConfirmed(task.id!);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Delete', style: GoogleFonts.nunito(color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}

/// Add / Edit Dialog (rounded, login-like style)
class AddEditTaskDialog extends StatefulWidget {
  final bool isEdit;
  final TaskController controller;
  const AddEditTaskDialog({Key? key, required this.isEdit, required this.controller}) : super(key: key);

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _form = GlobalKey<FormState>();
  final DateTime start = DateTime.now();
  bool loading = false;
  bool _showRepeatOptions = false;

  // small fixed timeline height to avoid overflow
  static const double _timelineHeight = 92;

  Future<void> _showTimePicker() async {
    final initial = widget.controller.pickedTime ?? TimeOfDay.now();

    await Navigator.of(context).push(
      showPicker(
        context: context,
        value: Time(hour: initial.hour, minute: initial.minute),
        onChange: (time) {
          final chosen = TimeOfDay(hour: time.hour, minute: time.minute);

          // If date is today → disallow selecting past times
          if (widget.controller.pickedDate != null) {
            final d = widget.controller.pickedDate!;
            final combined = DateTime(d.year, d.month, d.day, chosen.hour, chosen.minute);

            if (combined.isBefore(DateTime.now())) {
              Get.snackbar('Invalid', 'Please choose a future time');
              return;
            }
          }

          widget.controller.setPickedTime(chosen);

          // update ISO combined datetime
          if (widget.controller.pickedDate != null) {
            final d = widget.controller.pickedDate!;
            final combined = DateTime(d.year, d.month, d.day, chosen.hour, chosen.minute);
            widget.controller.dateController.text = combined.toIso8601String();
          }

          setState(() {});
        },
        is24HrFormat: false,
        iosStylePicker: false,
      ),
    );
  }


  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _displayPicked() {
    if (widget.controller.pickedDate == null && widget.controller.pickedTime == null) return 'Pick date & time (optional)';
    final date = widget.controller.pickedDate;
    final time = widget.controller.pickedTime;
    if (date == null) {
      if (time == null) return 'Pick date & time (optional)';
      return 'Time: ${time.format(context)}';
    }
    if (time == null) {
      return '${date.day}/${date.month}/${date.year} • pick time';
    }
    return '${date.day}/${date.month}/${date.year} • ${time.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final w = Get.width;

    // ensure when opened for edit the fields already set by controller.startEdit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {}); // update UI from controller pickedDate/pickedTime if needed
    });

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              gradient: LinearGradient(colors: [Color(0xFFeaf4f2), Colors.white])),
          child: Form(
            key: _form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(widget.isEdit ? 'Edit Task' : 'New Task', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 12),

              TextFormField(
                controller: widget.controller.titleController,
                decoration: _inputDecor('Task name', Icons.edit, w),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a task name' : null,
              ),
              SizedBox(height: 12),

              SizedBox(
                height: _timelineHeight,
                child: DatePicker(
                  start,
                  initialSelectedDate: widget.controller.pickedDate ?? start,
                  selectionColor: kTeal,
                  selectedTextColor: Colors.white,
                  dayTextStyle: TextStyle(fontSize: 12),
                  dateTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  monthTextStyle: TextStyle(fontSize: 10),
                  onDateChange: (date) {
                    // disallow selecting a past date
                    final now = DateTime.now();
                    final chooseDate = date.isBefore(DateTime(now.year, now.month, now.day)) ? DateTime(now.year, now.month, now.day) : date;
                    widget.controller.setPickedDate(chooseDate);
                    if (widget.controller.pickedTime != null) {
                      final t = widget.controller.pickedTime!;
                      final combined = DateTime(chooseDate.year, chooseDate.month, chooseDate.day, t.hour, t.minute);
                      widget.controller.dateController.text = combined.toIso8601String();
                    }
                    setState(() {});
                  },
                ),
              ),

              SizedBox(height: 10),

              GestureDetector(
                onTap: _showTimePicker,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(w * 0.05)),
                  child: Row(children: [
                    Icon(Icons.access_time, color: kTeal),
                    SizedBox(width: 12),
                    Expanded(child: Text(_displayPicked(), style: GoogleFonts.nunito())),
                    Icon(Icons.keyboard_arrow_down)
                  ]),
                ),
              ),

              SizedBox(height: 12),





              // visible only when both date & time selected

              // reminder
              if (widget.controller.showAlarmCheckbox())
                Obx(() => Column(
                  children: [

                    /// 🔔 REMINDER (replaces Set alarm + Vibrate)
                    Row(
                      children: [
                        Checkbox(
                          value: widget.controller.reminderEnabled.value,
                          activeColor: kTeal,
                          onChanged: (v) =>
                          widget.controller.reminderEnabled.value = v ?? false,
                        ),
                        Text(
                          'Reminder',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    /// 💊 MEDICINE (TAG ONLY)
                    Row(
                      children: [
                        Checkbox(
                          value: widget.controller.isMedicine.value,
                          activeColor: kTeal,
                          onChanged: (v) =>
                          widget.controller.isMedicine.value = v ?? false,
                        ),
                        Text(
                          'Medicine',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                )),


              // medicine
              if (widget.controller.showAlarmCheckbox())
                Obx(() => GestureDetector(
                  onTap: () => setState(() => _showRepeatOptions = !_showRepeatOptions),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _showRepeatOptions ? kTeal.withOpacity(0.4) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.repeat, color: kTeal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _repeatLabel(widget.controller),
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _showRepeatOptions ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                  ),
                )),

              // repeat
              if (_showRepeatOptions)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: !_showRepeatOptions
                      ? const SizedBox.shrink()
                      : _RepeatOptions(controller: widget.controller),
                ),




              SizedBox(height: 12),

              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  // if date chosen but no time -> ask
                  if (widget.controller.pickedDate != null && widget.controller.pickedTime == null) {
                    Get.snackbar('Validation', 'Pick time or clear the date (alarm requires date+time)');
                    return;
                  }

                  // if date is today + time picked ensure future
                  if (widget.controller.pickedDate != null && widget.controller.pickedTime != null) {
                    final combined = DateTime(widget.controller.pickedDate!.year, widget.controller.pickedDate!.month, widget.controller.pickedDate!.day, widget.controller.pickedTime!.hour, widget.controller.pickedTime!.minute);
                    if (!combined.isAfter(DateTime.now())) {
                      Get.snackbar('Validation', 'Select a future date/time');
                      return;
                    }
                  }

                  setState(() => loading = true);
                  if (widget.isEdit) {
                    await widget.controller.confirmEdit();
                  } else {
                    await widget.controller.addTask();
                  }
                  setState(() => loading = false);
                  Navigator.pop(context,true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTeal,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.05)),
                ),
                child: loading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                    : Text(widget.isEdit ? 'Save Changes' : 'Add Task', style: GoogleFonts.nunito(color: Colors.white)),
              ),

              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  widget.controller.clearForm();
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: GoogleFonts.nunito(color: Colors.grey)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon, double w) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kTeal),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(w * 0.05), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(w * 0.05), borderSide: BorderSide(color: kTeal, width: 1.3)),
    );
  }
  String _repeatLabel(TaskController c) {
    switch (c.repeatType.value) {
      case 'daily': return 'Repeat: Daily';
      case 'tomorrow': return 'Repeat: Tomorrow';
      case 'custom': return 'Repeat: ${c.repeatDays.join(', ')}';
      default: return 'Repeat: Never';
    }
  }
  Widget _repeatTile(String text, VoidCallback onTap) {
    return ListTile(
      dense: true,
      title: Text(text, style: GoogleFonts.nunito()),
      onTap: onTap,
    );
  }


}
class _RepeatOptions extends StatelessWidget {
  final TaskController controller;
  const _RepeatOptions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('repeat-options'),
      children: [
        const SizedBox(height: 8),

        RepeatCard(
          label: 'Tomorrow',
          selected: controller.repeatType.value == 'tomorrow',
          onTap: () {
            controller.repeatType.value = 'tomorrow';
            controller.repeatDays.clear();
          },
        ),

        RepeatCard(
          label: 'Daily',
          selected: controller.repeatType.value == 'daily',
          onTap: () {
            controller.repeatType.value = 'daily';
            controller.repeatDays.clear();
          },
        ),

        RepeatCard(
          label: 'Custom',
          selected: controller.repeatType.value == 'custom',
          onTap: () {
            controller.repeatType.value = 'custom';
          },
        ),

        if (controller.repeatType.value == 'custom') ...[
          const SizedBox(height: 10),
          CustomDayChips(controller: controller),
        ],
      ],
    );

  }



}





