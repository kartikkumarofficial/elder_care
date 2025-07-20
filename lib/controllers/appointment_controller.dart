import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

class AppointmentController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  String? _managedUserId;

  final RxList<Appointment> appointments = <Appointment>[].obs;
  final isLoading = false.obs;

  Future<void> initializeForUser(String userId) async {
    _managedUserId = userId;
    await fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    if (_managedUserId == null) return;
    isLoading.value = true;
    try {
      final response = await supabase
          .from('appointments')
          .select()
          .eq('user_id', _managedUserId!)
          .order('appointment_datetime', ascending: true);

      appointments.value = (response as List).map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch appointments.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAppointment(String title, String? location, DateTime dateTime) async {
    if (_managedUserId == null) return;
    try {
      final response = await supabase
          .from('appointments')
          .insert({
        'user_id': _managedUserId,
        'title': title,
        'location': location,
        'appointment_datetime': dateTime.toIso8601String(),
      })
          .select();

      final newAppointment = Appointment.fromJson((response as List).first);
      appointments.add(newAppointment);
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    } catch (e) {
      Get.snackbar('Error', 'Failed to add appointment.');
    }
  }

  Future<void> deleteAppointment(int appointmentId) async {
    appointments.removeWhere((appt) => appt.id == appointmentId);
    await supabase.from('appointments').delete().eq('id', appointmentId);
  }
}
