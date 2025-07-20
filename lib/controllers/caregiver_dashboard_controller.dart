import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Placeholder model for medication reminders
class Medication {
  final String name;
  final String time;
  Medication({required this.name, required this.time});
}

class CaregiverDashboardController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final userName = ''.obs; // This will be the receiver's name

  // Using placeholder data for the UI to build correctly.
  // This would be replaced with data from your 'tasks' table.
  final RxList<Medication> medications = <Medication>[
    Medication(name: "Metformin", time: "8:00 AM"),
    Medication(name: "Lisinopril", time: "8:00 AM"),
    Medication(name: "Atorvastatin", time: "8:00 PM"),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReceiverData();
  }

  Future<void> fetchReceiverData() async {
    isLoading.value = true;
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      // Get the caregiver's record to find the linked user ID
      final caregiverResponse = await supabase
          .from('users')
          .select('linked_user_id')
          .eq('id', currentUser.id)
          .single();

      final linkedUserId = caregiverResponse['linked_user_id'];

      if (linkedUserId != null) {
        // Fetch the receiver's name using the linked ID
        final receiverResponse = await supabase
            .from('users')
            .select('full_name')
            .eq('id', linkedUserId)
            .single();
        // The caregiver sees the name of the person they are caring for.
        userName.value = receiverResponse['full_name'] ?? 'Client';
      } else {
        userName.value = 'Not Linked';
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load client data.');
      userName.value = 'Error';
    } finally {
      isLoading.value = false;
    }
  }

  // Placeholder methods for the UI buttons to work without error.
  void openNotificationDrawer() {
    Get.snackbar("Info", "Notifications drawer would open here.");
  }

  void deleteMedication(Medication med) {
    Get.snackbar("Info", "${med.name} would be deleted. This needs to be implemented.");
  }

  void showAddMedicationBottomSheet() {
    Get.snackbar("Info", "A bottom sheet to add reminders would appear here.");
  }
}
