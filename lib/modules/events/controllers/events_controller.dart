import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../../../core/models/event_model.dart';

const Color kTeal = Color(0xFF7AB7A7);
const Color kTealLight = Color(0xFFBFEDE2);
const double kCardRadius = 16.0;
const double kCardHeight = 110.0;


class SupabaseEventService {
  static final supabase = Supabase.instance.client;

  static Future<List<EventModel>> fetchEvents(String receiverId) async {
    final res = await supabase
        .from('events')
        .select()
        .eq('receiver_id', receiverId)
        .order('event_time', ascending: true);

    if (res is List) {
      return res
          .map<EventModel>(
              (e) => EventModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static Future<EventModel?> createEvent(EventModel event) async {
    final res = await supabase
        .from('events')
        .insert(event.toMap())
        .select()
        .single();

    if (res != null) {
      return EventModel.fromMap(Map<String, dynamic>.from(res));
    }
    return null;
  }

  static Future<EventModel?> updateEvent(EventModel event) async {
    if (event.id == null) return null;

    final res = await supabase
        .from('events')
        .update({
      'title': event.title,
      'event_time': event.eventTime,
      'category': event.category,
      'notes': event.notes,
    })
        .eq('id', event.id!)
        .select()
        .single();

    if (res != null) {
      return EventModel.fromMap(Map<String, dynamic>.from(res));
    }
    return null;
  }

  static Future<void> deleteEvent(int id) async {
    await supabase.from('events').delete().eq('id', id);
  }
}

// controller
class EventsController extends GetxController {
  final RxList<EventModel> events = <EventModel>[].obs;

  String? currentReceiverId;

  // ---------------- FORM ----------------
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final notesController = TextEditingController();
  final category = 'Medication'.obs;

  final List<String> categories = [
    'Medication',
    'Appointment',
    'Vitals',
    'Activity',
    'Reminder',
    'Other',
    'General',
  ];

  int? editingId;
  DateTime? pickedDate;
  TimeOfDay? pickedTime;

  // ---------------- CLEANUP ----------------
  @override
  void onClose() {
    titleController.dispose();
    dateController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void clearForm() {
    titleController.clear();
    dateController.clear();
    notesController.clear();
    category.value = 'Medication';
    editingId = null;
    pickedDate = null;
    pickedTime = null;
  }

  // ---------------- LOADING ----------------
  Future<void> loadEventsForReceiver(String receiverId) async {
    currentReceiverId = receiverId;

    try {
      final list =
      await SupabaseEventService.fetchEvents(receiverId);

      events.assignAll(list);
    } catch (e) {
      debugPrint('fetchEvents error: $e');
      Get.snackbar('Error', 'Failed to load events');
    }
  }

  Future<void> refreshEvents() async {
    if (currentReceiverId == null) return;
    await loadEventsForReceiver(currentReceiverId!);
  }

  // ---------------- HELPERS ----------------
  DateTime? _combinedDateTime() {
    if (pickedDate == null && pickedTime == null) return null;

    final d = pickedDate ?? DateTime.now();
    final t = pickedTime ?? const TimeOfDay(hour: 9, minute: 0);

    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  bool _isFutureSelected() {
    final combined = _combinedDateTime();
    return combined != null && combined.isAfter(DateTime.now());
  }

  // ---------------- CREATE ----------------
  Future<bool> addEvent() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Enter event title');
      return false;
    }

    if (!_isFutureSelected()) {
      Get.snackbar('Validation', 'Select future date & time');
      return false;
    }

    if (currentReceiverId == null) {
      Get.snackbar('Error', 'No receiver selected');
      return false;
    }

    final model = EventModel(
      receiverId: currentReceiverId!,
      title: titleController.text.trim(),
      eventTime: _combinedDateTime()!,
      category: category.value,
      notes: notesController.text.trim(),
    );

    final created =
    await SupabaseEventService.createEvent(model);

    if (created != null) {
      events.add(created);
      events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
      Get.snackbar('Success', 'Event added');
      return true;
    }

    return false;
  }

  // ---------------- EDIT ----------------
  Future<void> startEdit(EventModel event) async {
    editingId = event.id;
    titleController.text = event.title;
    notesController.text = event.notes;
    category.value =
    categories.contains(event.category.trim())
        ? event.category.trim()
        : categories.first;

    final dt = event.eventTime.toLocal();
    pickedDate = DateTime(dt.year, dt.month, dt.day);
    pickedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  Future<bool> confirmEdit() async {
    if (editingId == null) return false;

    final model = EventModel(
      id: editingId, // 🔥 CRITICAL FIX
      receiverId: currentReceiverId!,
      title: titleController.text.trim(),
      eventTime: _combinedDateTime()!,
      category: category.value,
      notes: notesController.text.trim(),
    );

    final updated =
    await SupabaseEventService.updateEvent(model);

    if (updated != null) {
      final idx =
      events.indexWhere((e) => e.id == updated.id);
      if (idx != -1) events[idx] = updated;

      events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
      Get.snackbar('Success', 'Event updated');
      return true;
    }

    return false;
  }

  // ---------------- DELETE ----------------
  Future<void> deleteEventConfirmed(int id) async {
    await SupabaseEventService.deleteEvent(id);
    events.removeWhere((e) => e.id == id);
    Get.snackbar('Deleted', 'Event removed');
  }
}
