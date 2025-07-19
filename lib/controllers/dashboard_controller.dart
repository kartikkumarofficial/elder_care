import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Medication {
  final String name;
  final String time;

  Medication({required this.name, required this.time});
}

class DashboardController extends GetxController {
  var isLoading = false.obs;

  var userName = "Kartik".obs;

  // Medication reminders
  var medications = <Medication>[
    Medication(name: "Paracetamol", time: "8:00 AM"),
    Medication(name: "Vitamin D3", time: "12:00 PM"),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  /// Simulate fetching dashboard data
  void fetchDashboardData() async {
    isLoading.value = true;

    // simulate delay for loading
    await Future.delayed(Duration(seconds: 1));

    // You could integrate Supabase, Firebase, or APIs here
    userName.value = "Kartik"; // Replace with dynamic value

    isLoading.value = false;
  }

  /// Open notifications (could be a drawer or navigate to another screen)
  void openNotificationDrawer() {
    Get.snackbar("Notifications", "No new alerts right now.",
        backgroundColor: Colors.grey[850], colorText: Colors.white);
  }

  /// Show dialog to add new medication
  void showAddMedicationDialog() {
    String medName = '';
    String medTime = '';

    Get.defaultDialog(
      title: "Add Medication",
      titleStyle: TextStyle(color: Colors.white),
      backgroundColor: Color(0xFF1E1E1E),
      content: Column(
        children: [
          TextField(
            onChanged: (val) => medName = val,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Medication Name',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          TextField(
            onChanged: (val) => medTime = val,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Time (e.g. 10:00 AM)',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (medName.isNotEmpty && medTime.isNotEmpty) {
                medications.add(Medication(name: medName, time: medTime));
                Get.back();
              } else {
                Get.snackbar("Error", "Please fill in all fields",
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white);
              }
            },
            child: Text("Add"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
            ),
          )
        ],
      ),
    );
  }

  /// Delete a medication
  void deleteMedication(Medication med) {
    medications.remove(med);
    Get.snackbar("Deleted", "${med.name} reminder removed.",
        backgroundColor: Colors.grey[800], colorText: Colors.white);
  }
}
