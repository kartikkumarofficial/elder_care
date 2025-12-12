
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

import '../controllers/events_controller.dart';
import '../../../core/models/event_model.dart';


class EventSectionModern extends StatelessWidget {
  EventSectionModern({Key? key}) : super(key: key);

  final EventsController controller = Get.put(EventsController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        SizedBox(height: 12),
        _horizontalList(),
      ],
    );
  }

  Widget _header(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(
          child: Text('Events', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        GestureDetector(
          onTap: () {
            controller.clearForm();
            _openAddDialog(ctx, isEdit: false);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kTeal,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: kTeal.withOpacity(0.22), blurRadius: 8, offset: Offset(0, 5))],
            ),
            child: Row(children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text('Add', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _horizontalList() {
    return SizedBox(
      height: kCardHeight,
      child: Obx(() {
        final events = controller.events;
        if (events.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left:20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text('No events yet', style: GoogleFonts.nunito(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(left: 20),
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          itemBuilder: (_, i) {
            final e = events[i];
            return _EventCardCompact(event: e);
          },
        );
      }),
    );
  }

  void _openAddDialog(BuildContext ctx, {required bool isEdit}) {
    showDialog(
      context: ctx,
      builder: (_) => AddEditEventDialog(isEdit: isEdit, controller: controller),
    );
  }
}

/// =================================================
/// COMPACT CARD (smaller height, safe layout)
/// =================================================
/// =================================================
/// IMPROVED COMPACT EVENT CARD — matches login theme
/// =================================================
class _EventCardCompact extends StatelessWidget {
  final EventModel event;
  const _EventCardCompact({Key? key, required this.event}) : super(key: key);

  String _friendlyDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year} • ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  IconData _iconForCategory(String c) {
    switch (c) {
      case 'Medication':
        return Icons.medication;
      case 'Appointment':
        return Icons.medical_services;
      case 'Vitals':
        return Icons.favorite;
      case 'Activity':
        return Icons.directions_walk;
      case 'Reminder':
        return Icons.notifications;
      default:
        return Icons.event;
    }
  }

  Color _colorForCategory(String c) {
    switch (c) {
      case 'Medication':
        return Colors.orange.shade300;
      case 'Appointment':
        return Colors.blue.shade300;
      case 'Vitals':
        return Colors.red.shade300;
      case 'Activity':
        return Colors.green.shade300;
      case 'Reminder':
        return Colors.purple.shade300;
      default:
        return kTealLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctl = Get.find<EventsController>();

    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (_) => EventDetailsDialog(event: event));
      },
      onLongPress: () {
        ctl.startEdit(event);
        showDialog(context: context, builder: (_) => EditDeleteDialog(event: event));
      },
      child: Container(
        width: Get.width * 0.63,
        height: kCardHeight,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kCardRadius + 6),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 12,
          //     offset: Offset(0, 5),
          //   )
          // ],
          gradient: LinearGradient(
            colors: [
              Color(0xFFeaf4f2),
              Color(0xFFfdfaf6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            // Left side Icon bubble
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _colorForCategory(event.category).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _colorForCategory(event.category).withOpacity(0.35),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Icon(
                _iconForCategory(event.category),
                color: Colors.white,
                size: 30,
              ),
            ),

            SizedBox(width: 14),

            // Right side text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    _friendlyDate(event.datetime),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: Colors.black54,
                      fontSize: 13.2,
                    ),
                  ),

                  Spacer(),

                  // Category chip
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kTealLight.withOpacity(0.6)),
                        ),
                        child: Text(
                          event.category,
                          style: GoogleFonts.nunito(
                            fontSize: 12.5,
                            color: kTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// =================================================
/// DETAILS DIALOG (tap) — contains Edit & Delete buttons
/// =================================================
class EventDetailsDialog extends StatelessWidget {
  final EventModel event;
  const EventDetailsDialog({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctl = Get.find<EventsController>();
    DateTime? dt;
    try {
      dt = DateTime.parse(event.datetime);
    } catch (_) {}

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(event.title, style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800)),
          SizedBox(height: 10),
          if (dt != null)
            Text('${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.nunito(color: Colors.black54)),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Category', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(event.category, style: GoogleFonts.nunito(color: kTeal)),
          ),
          SizedBox(height: 10),
          if (event.notes.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Align(alignment: Alignment.centerLeft, child: Text('Notes', style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
              SizedBox(height: 6),
              Text(event.notes, style: GoogleFonts.nunito()),
              SizedBox(height: 12),
            ]),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ctl.startEdit(event);
                  Navigator.pop(context);
                  showDialog(context: context, builder: (_) => AddEditEventDialog(isEdit: true, controller: ctl));
                },
                style: ElevatedButton.styleFrom(backgroundColor: kTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Edit', style: GoogleFonts.nunito(color: Colors.white)),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmDelete(context, ctl, event.id),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Delete', style: GoogleFonts.nunito(color: Colors.white)),
              ),
            ),
          ])
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, EventsController ctl, int? id) {
    if (id == null) return;
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('Delete Event', style: GoogleFonts.nunito()),
        content: Text('Are you sure you want to delete this event?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.nunito())),
          ElevatedButton(
            onPressed: () => ctl.deleteEventConfirmed(id),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Delete', style: GoogleFonts.nunito(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// =================================================
/// EDIT/DELETE QUICK DIALOG (long-press)
/// =================================================
class EditDeleteDialog extends StatelessWidget {
  final EventModel event;
  const EditDeleteDialog({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctl = Get.find<EventsController>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: EdgeInsets.all(14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Manage Event', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ctl.startEdit(event);
              showDialog(context: context, builder: (_) => AddEditEventDialog(isEdit: true, controller: ctl));
            },
            style: ElevatedButton.styleFrom(backgroundColor: kTeal),
            child: Text('Edit', style: GoogleFonts.nunito(color: Colors.white)),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ctl.deleteEventConfirmed(event.id!),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Delete', style: GoogleFonts.nunito(color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}

/// =================================================
/// ADD / EDIT DIALOG (rounded card style — A)
/// =================================================
class AddEditEventDialog extends StatefulWidget {
  final bool isEdit;
  final EventsController controller;
  const AddEditEventDialog({Key? key, required this.isEdit, required this.controller}) : super(key: key);

  @override
  State<AddEditEventDialog> createState() => _AddEditEventDialogState();
}

class _AddEditEventDialogState extends State<AddEditEventDialog> {
  final _form = GlobalKey<FormState>();
  bool loading = false;

  // DatePicker needs a starting date; we show timeline from today
  final DateTime start = DateTime.now();

  // Use a small fixed height for the timeline to avoid overflow
  static const double _timelineHeight = 92;

  // Open day-night time picker (animated)
  Future<void> _showTimePicker() async {
    final initial = widget.controller.pickedTime ?? TimeOfDay.now();

    // The day_night_time_picker package often expects Navigator.push(showPicker(...))
    // We'll push the route returned by showPicker so it opens reliably.
    await Navigator.of(context).push(
      showPicker(
        context: context,
        value: Time(hour: initial.hour, minute: initial.minute),
        onChange: (time) {
          final t = TimeOfDay(hour: time.hour, minute: time.minute);
          widget.controller.pickedTime = t;

          if (widget.controller.pickedDate != null) {
            final combined = DateTime(widget.controller.pickedDate!.year, widget.controller.pickedDate!.month,
                widget.controller.pickedDate!.day, t.hour, t.minute);
            widget.controller.dateController.text = combined.toIso8601String();
          } else {
            final now = DateTime.now();
            final combined = DateTime(now.year, now.month, now.day, t.hour, t.minute);
            widget.controller.dateController.text = combined.toIso8601String();
          }
          setState(() {});
        },
        // small appearance tweaks
        iosStylePicker: false,
        // optional: darkStyle: true,
      ),
    );
  }

  String _displayPicked() {
    if (widget.controller.pickedDate == null && widget.controller.pickedTime == null) return 'Select date & time';
    final date = widget.controller.pickedDate;
    final time = widget.controller.pickedTime;
    if (date == null) {
      if (time == null) return 'Select date & time';
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
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              gradient: LinearGradient(colors: [Color(0xFFeaf4f2), Colors.white])),
          child: Form(
            key: _form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // header
              Text(widget.isEdit ? 'Edit Event' : 'New Event', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800)),
              SizedBox(height: 12),

              // Title
              TextFormField(
                controller: widget.controller.titleController,
                decoration: _inputDecor('Event Name', Icons.edit, w),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              SizedBox(height: 12),

              // Date timeline - fixed height to avoid overflow
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
                    // date selected
                    widget.controller.pickedDate = date.isBefore(DateTime.now()) ? DateTime.now() : date;
                    if (widget.controller.pickedTime != null) {
                      final t = widget.controller.pickedTime!;
                      final combined = DateTime(date.year, date.month, date.day, t.hour, t.minute);
                      widget.controller.dateController.text = combined.toIso8601String();
                    }
                    setState(() {});
                  },
                ),
              ),

              SizedBox(height: 10),

              // Time picker trigger (animated)
              GestureDetector(
                onTap: _showTimePicker,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(w * 0.05)),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: kTeal),
                      SizedBox(width: 12),
                      Expanded(child: Text(_displayPicked(), style: GoogleFonts.nunito())),
                      Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Category dropdown (reactive only for value)
              Obx(() {
                return DropdownButtonFormField<String>(
                  value: widget.controller.category.value,
                  items: widget.controller.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => widget.controller.category.value = v ?? widget.controller.category.value,
                  decoration: _inputDecor('Category', Icons.category, w),
                );
              }),

              SizedBox(height: 12),

              // Notes (multiline)
              TextFormField(
                controller: widget.controller.notesController,
                minLines: 2,
                maxLines: 4,
                decoration: _inputDecor('Notes (optional)', Icons.note, w),
              ),

              SizedBox(height: 16),

              // Save button
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  if (widget.controller.pickedDate == null || widget.controller.pickedTime == null) {
                    Get.snackbar('Validation', 'Pick date and time (future)');
                    return;
                  }
                  final combined = DateTime(
                      widget.controller.pickedDate!.year,
                      widget.controller.pickedDate!.month,
                      widget.controller.pickedDate!.day,
                      widget.controller.pickedTime!.hour,
                      widget.controller.pickedTime!.minute);
                  if (!combined.isAfter(DateTime.now())) {
                    Get.snackbar('Validation', 'Select a future date/time');
                    return;
                  }

                  setState(() => loading = true);
                  if (widget.isEdit) {
                    await widget.controller.confirmEdit();
                  } else {
                    await widget.controller.addEvent();
                  }
                  setState(() => loading = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTeal,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.05)),
                ),
                child: loading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                    : Text(widget.isEdit ? 'Save Changes' : 'Add Event', style: GoogleFonts.nunito(color: Colors.white)),
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
