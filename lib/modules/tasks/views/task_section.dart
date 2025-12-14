// lib/presentation/widgets/tasks/task_section.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import '../controllers/task_controller.dart';
import '../../../core/models/task_model.dart';
import '../../dashboard/controllers/nav_controller.dart';

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
          receiverIdOverride != null
              ? "No tasks available"
              : "No receiver linked yet",
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
                  final t = list[i];
                  final parsed = t.datetime != null
                      ? DateTime.tryParse(t.datetime!)
                      : null;
                  final isOverdue =
                      parsed != null && parsed.isBefore(DateTime.now());
              
                  return GestureDetector(
                    onTap: () => _openDetailsDialog(context, t),
                    onLongPress: () => _openDetailsDialog(context, t),
                    // {
                    //   controller.startEdit(t);
                    //   showDialog(
                    //       context: context,
                    //       builder: (_) =>
                    //           _EditDeleteDialog(task: t, controller: controller));
                    // },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6F7), // soft subtle background
                        borderRadius: BorderRadius.circular(22), // pill shape
                        border: Border.all(
                          color: const Color(0xFFE1E6E8),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          /// 🔵 Leading icon bubble
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFFE3E7EA)),
                            ),
                            child: Icon(
                              Icons.task_alt_rounded,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(width: 14),

                          /// 🔤 Text + date/time section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// TITLE
                                Text(
                                  t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),

                                SizedBox(height: 6),

                                /// TIME + optional ALARM
                                Row(
                                  children: [
                                    Text(
                                      t.datetime != null
                                          ? _friendlyDate(t.datetime!)
                                          : "",
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),

                                    if (t.alarmEnabled) ...[
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.alarm,
                                        size: 16,
                                        color: Colors.black54, // black as requested
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          /// ⋮ MORE ICON
                          GestureDetector(
                            onTap: () => _openDetailsDialog(context, t),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),





                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _friendlyDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day}/${d.month}/${d.year} • ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

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
                  // immediate delete, no confirm
                  controller.deleteTaskConfirmed(task.id!);
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

              // Alarm checkbox — visible only when both date & time selected
              if (widget.controller.showAlarmCheckbox())
                Row(children: [
                  Obx(() => Checkbox(
                    value: widget.controller.alarmEnabled.value,
                    onChanged: (v) => widget.controller.alarmEnabled.value = v ?? false,
                  )),
                  SizedBox(width: 8),
                  Text('Set alarm', style: GoogleFonts.nunito()),
                ]),

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
                  Navigator.pop(context);
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
}
