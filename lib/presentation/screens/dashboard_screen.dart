
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

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark, // Apply primary dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar for modern look
        elevation: 0, // No shadow for app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () {
            // Handle back button action
            Get.back(); // Example: Go back if there's a previous screen
          },
        ),
        title: Text(
          "Caregiver",
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false, // Align title to start
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: AppColors.textLight),
            onPressed: controller.openNotificationDrawer,
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: AppColors.textLight),
            onPressed: () {
              // Handle profile button action
            },
          ),
          const SizedBox(width: 8), // Spacing for actions
        ],
      ),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.accentCoral, // Themed loading indicator
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${controller.userName.value}!",
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.8), // Slightly subdued for greeting
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              _buildVitalSignsGrid(),
              const SizedBox(height: 30),
              Text(
                "Medication Reminders",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildMedicationList(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  onPressed: controller.showAddMedicationBottomSheet, // Call the new bottom sheet method
                  icon: Icon(Icons.add_circle_outline, color: AppColors.textLight),
                  label: Text(
                    "Add New Reminder",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCoral, // Themed button background
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Pill-shaped button
                    ),
                    elevation: 8, // Elevated shadow
                    shadowColor: AppColors.accentCoral.withOpacity(0.4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildVitalSignsGrid() {
    return GridView.count(
      shrinkWrap: true, // Important for nested scroll views
      physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5, // Adjust aspect ratio for card size
      children: [
        _buildMetricCard(
          icon: Icons.favorite_border,
          title: "Heart Rate",
          value: "78 BPM",
          trend: "+5%", // Example trend
          iconColor: Colors.redAccent,
        ),
        _buildMetricCard(
          icon: Icons.bloodtype_outlined,
          title: "Blood Sugar",
          value: "120 mg/dL",
          iconColor: Colors.purpleAccent,
        ),
        _buildMetricCard(
          icon: Icons.water_drop_outlined,
          title: "Hydration",
          value: "2.5 L",
          iconColor: Colors.lightBlueAccent,
        ),
        _buildMetricCard(
          icon: Icons.directions_walk_outlined,
          title: "Steps",
          value: "3,480",
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? trend,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground, // Themed card background
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5), // Subtle shadow for depth
          ),
        ],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor?.withOpacity(0.2) ?? AppColors.iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10), // Rounded icon background
                ),
                child: Icon(icon, color: iconColor ?? AppColors.iconColor, size: 28),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textLight.withOpacity(0.7), // Slightly muted title
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textLight, // Bright text for values
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trend != null)
                Text(
                  trend,
                  style: TextStyle(
                    color: Colors.greenAccent, // Green for positive trend
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return Obx(
          () => controller.medications.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No medication reminders yet. Tap 'Add New Reminder' to get started!",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight.withOpacity(0.6), fontSize: 16),
          ),
        ),
      )
          : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Disable list scrolling
        itemCount: controller.medications.length,
        itemBuilder: (context, index) {
          final med = controller.medications[index];
          return Dismissible(
            key: Key(med.name + med.time + index.toString()), // Unique key for Dismissible
            direction: DismissDirection.endToStart, // Swipe from right to left
            onDismissed: (direction) {
              controller.deleteMedication(med);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent, // Red background for delete action
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
            ),
            child: Card(
              color: AppColors.cardBackground, // Themed card background for list items
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              elevation: 4, // Subtle shadow
              shadowColor: Colors.black.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.accentCoral, size: 30), // Themed icon
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Scheduled: ${med.time}",
                            style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.iconColor, size: 24), // Navigation indicator
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground, // Themed bottom nav background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), // Rounded top corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -10), // Shadow from top
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BottomNavigationBar(
          backgroundColor: AppColors.cardBackground, // Ensure it matches container
          selectedItemColor: AppColors.accentCoral, // Themed selected icon
          unselectedItemColor: AppColors.iconColor, // Themed unselected icons
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Prevent icon shifting
          elevation: 0, // No default shadow
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Health",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              label: "Location",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: "More",
            ),
          ],
        ),
      ),
    );
  }
}

