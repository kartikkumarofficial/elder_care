
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_theme.dart';

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
    await Future.delayed(const Duration(seconds: 1));

    // You could integrate Supabase, Firebase, or APIs here
    userName.value = "Kartik"; // Replace with dynamic value

    isLoading.value = false;
  }

  /// Open notifications (could be a drawer or navigate to another screen)
  void openNotificationDrawer() {
    Get.snackbar(
      "Notifications",
      "No new alerts right now.",
      backgroundColor: AppColors.cardBackground, // Themed background
      colorText: AppColors.textLight, // Themed text color
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Show a modern bottom sheet to add new medication
  void showAddMedicationBottomSheet() {
    String medName = '';
    String medTime = '';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground, // Use card background for bottom sheet
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep column size to content
          children: [
            Text(
              "Add New Reminder",
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (val) => medName = val,
              style: TextStyle(color: AppColors.textLight),
              cursorColor: AppColors.accentCoral, // Themed cursor
              decoration: InputDecoration(
                hintText: 'Medication Name',
                hintStyle: TextStyle(color: AppColors.iconColor.withOpacity(0.7)),
                filled: true,
                fillColor: AppColors.primaryDark.withOpacity(0.5), // Subtle fill for input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // No border by default
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentCoral, width: 2), // Themed focused border
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (val) => medTime = val,
              style: TextStyle(color: AppColors.textLight),
              cursorColor: AppColors.accentCoral,
              decoration: InputDecoration(
                hintText: 'Time (e.g. 10:00 AM)',
                hintStyle: TextStyle(color: AppColors.iconColor.withOpacity(0.7)),
                filled: true,
                fillColor: AppColors.primaryDark.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentCoral, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (medName.isNotEmpty && medTime.isNotEmpty) {
                    medications.add(Medication(name: medName, time: medTime));
                    Get.back(); // Close bottom sheet
                    Get.snackbar(
                      "Success",
                      "Medication reminder added!",
                      backgroundColor: AppColors.successGreen,
                      colorText: AppColors.textLight,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  } else {
                    Get.snackbar(
                      "Error",
                      "Please fill in all fields",
                      backgroundColor: AppColors.warningOrange,
                      colorText: AppColors.textLight,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCoral, // Use accent color for button
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5, // Subtle shadow for depth
                  shadowColor: AppColors.accentCoral.withOpacity(0.4),
                ),
                child: Text(
                  "Add Reminder",
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true, // Allows the bottom sheet to take full height if needed
    );
  }

  /// Delete a medication
  void deleteMedication(Medication med) {
    medications.remove(med);
    Get.snackbar(
      "Deleted",
      "${med.name} reminder removed.",
      backgroundColor: AppColors.primaryDark,
      colorText: AppColors.textLight,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
