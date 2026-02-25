import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../../../core/models/event_model.dart';

const Color kTeal = Color(0xFF7AB7A7);
const Color kTealLight = Color(0xFFBFEDE2);
const double kCardRadius = 16.0;
const double kCardHeight = 110.0;


/// =================================================
/// SUPABASE SERVICE (simple CRUD)
/// =================================================
class SupabaseEventService {
  static final supabase = Supabase.instance.client;

  static Future<List<EventModel>> fetchEvents() async {
    final res = await supabase.from('events').select().order('date', ascending: true);
    if (res is List) {
      return res
          .map<EventModel>((e) => EventModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  static Future<EventModel?> createEvent(EventModel event) async {
    final res = await supabase.from('events').insert(event.toMap()).select().single();
    if (res != null) return EventModel.fromMap(Map<String, dynamic>.from(res));
    return null;
  }

  static Future<EventModel?> updateEvent(EventModel event) async {
    if (event.id == null) return null;
    final res = await supabase
        .from('events')
        .update({
      'title': event.title,
      'date': event.datetime,
      'category': event.category,
      'notes': event.notes,
    })
        .eq('id', event.id!)
        .select()
        .single();
    if (res != null) return EventModel.fromMap(Map<String, dynamic>.from(res));
    return null;
  }

  static Future<void> deleteEvent(int id) async {
    await supabase.from('events').delete().eq('id', id);
  }
}

/// =================================================
/// CONTROLLER
/// =================================================
class EventsController extends GetxController {
  RxList<EventModel> events = <EventModel>[].obs;

  // Form controllers
  final titleController = TextEditingController();
  final dateController = TextEditingController(); // holds ISO datetime string
  final category = RxString('Medication');
  final notesController = TextEditingController();

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

  @override
  void onInit() {
    super.onInit();
    loadEvents();
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

  Future<void> loadEvents() async {
    try {
      final list = await SupabaseEventService.fetchEvents();
      events.assignAll(list);
    } catch (e) {
      debugPrint('fetchEvents error: $e');
      Get.snackbar('Error', 'Failed to load events');
    }
  }

  DateTime? _combinedDateTime() {
    if (pickedDate == null && pickedTime == null) return null;

    final d = pickedDate ?? DateTime.now();
    final t = pickedTime ?? const TimeOfDay(hour: 9, minute: 0);

    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }


  bool _isFutureSelected() {
    final combined = _combinedDateTime();
    if (combined == null) return false;
    return combined.isAfter(DateTime.now());
  }

  Future<bool> addEvent() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Enter event title');
      return false;
    }

    if (!_isFutureSelected()) {
      Get.snackbar('Validation', 'Please select a future date & time');
      return false;
    }

    final iso = _combinedDateTime()!.toIso8601String();

    final model = EventModel(
      title: titleController.text.trim(),
      datetime: iso,
      category: category.value,
      notes: notesController.text.trim(),
    );

    try {
      final created = await SupabaseEventService.createEvent(model);

      if (created != null) {
        events.insert(0, created);
        Get.snackbar('Success', 'Event added');
        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event');
      return false;
    }
  }

  Future<void> startEdit(EventModel event) async {
    editingId = event.id;
    titleController.text = event.title;
    notesController.text = event.notes;

    // 🔥 FIX: Ensure the category is valid
    final cleanCat = event.category.trim();
    if (categories.contains(cleanCat)) {
      category.value = cleanCat;
    } else {
      category.value = categories.first; // fallback
    }

    try {
      final dt = DateTime.parse(event.datetime);
      pickedDate = DateTime(dt.year, dt.month, dt.day);
      pickedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      dateController.text = dt.toIso8601String();
    } catch (_) {
      pickedDate = null;
      pickedTime = null;
      dateController.clear();
    }
  }


  Future<bool> confirmEdit() async {
    if (editingId == null) return false;

    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Enter event title');
      return false;
    }

    if (!_isFutureSelected()) {
      Get.snackbar('Validation', 'Please select a future date & time');
      return false;
    }

    final iso = _combinedDateTime()!.toIso8601String();

    final model = EventModel(
      id: editingId,
      title: titleController.text.trim(),
      datetime: iso,
      category: category.value,
      notes: notesController.text.trim(),
    );

    try {
      final updated = await SupabaseEventService.updateEvent(model);

      if (updated != null) {
        final idx = events.indexWhere((e) => e.id == updated.id);
        if (idx != -1) events[idx] = updated;

        Get.snackbar('Success', 'Event updated');
        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event');
      return false;
    }
  }

  Future<bool> deleteEventConfirmed(int id) async {
    try {
      await SupabaseEventService.deleteEvent(id);
      events.removeWhere((e) => e.id == id);

      Get.snackbar(
        'Deleted',
        'Event removed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete event',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return false;
    }
  }
}
