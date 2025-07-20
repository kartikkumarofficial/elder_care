import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/caregiver_dashboard_controller.dart'; // We will create this controller

class CaregiverDashboardScreen extends StatelessWidget {
  // Use the new CaregiverDashboardController
  final CaregiverDashboardController controller = Get.put(CaregiverDashboardController());

  CaregiverDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2A2E43),
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // This now correctly fetches the receiver's name
                      Text(
                        "Welcome back, ${controller.userName.value}",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Caretaker",
                          style: TextStyle(
                              fontSize: width * 0.035,
                              color: Colors.grey[400]))
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications,
                        size: width * 0.08, color: Colors.white),
                    onPressed: controller.openNotificationDrawer,
                  )
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle("Health Overview"),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _healthCard(width, "Heart Rate", "75 BPM", Icons.favorite, Colors.red),
                  _healthCard(width, "BP", "120/80", Icons.bloodtype, Colors.purple),
                  _healthCard(width, "Sugar", "95 mg/dL", Icons.water_drop, Colors.teal),
                  _healthCard(width, "Steps", "2,450", Icons.directions_walk, Colors.orange),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle("Reminders"),
              const SizedBox(height: 8),
              _remindersSection(controller, width),
              const SizedBox(height: 24),
              _sectionTitle("Location"),
              const SizedBox(height: 8),
              _locationSection(width),
              const SizedBox(height: 24),
              _sectionTitle("Appointments"),
              const SizedBox(height: 8),
              _appointmentsSection(),
              const SizedBox(height: 24),
              _emergencyButton(width),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: Get.width * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.white));
  }

  Widget _healthCard(double width, String title, String value, IconData icon, Color color) {
    return Container(
      width: (width - 48) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E6C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ],
          )
        ],
      ),
    );
  }

  Widget _remindersSection(CaregiverDashboardController controller, double width) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E6C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // This uses placeholder data from the new controller
          ...controller.medications.map((med) => ListTile(
            title: Text(med.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(med.time, style: const TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => controller.deleteMedication(med),
            ),
          )),
          TextButton.icon(
            onPressed: controller.showAddMedicationBottomSheet,
            icon: const Icon(Icons.add, color: Colors.blueAccent),
            label: const Text("Add Reminder", style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }

  Widget _locationSection(double width) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E6C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              // Ensure you have this image in your assets folder
              child: Image.asset('assets/images/map.png', fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(child: Text('Map not available', style: TextStyle(color: Colors.white))),
              )),
          const ListTile(
            title: Text("Last updated: 2 mins ago", style: TextStyle(color: Colors.grey)),
            trailing: TextButton(
              onPressed: null, // Disabled for now
              child: Text("Track Now", style: TextStyle(color: Colors.blueAccent)),
            ),
          )
        ],
      ),
    );
  }

  Widget _appointmentsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E6C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          ListTile(
            title: Text("Dr. Smith - Cardiology", style: TextStyle(color: Colors.white)),
            subtitle: Text("Today, 2:30 PM - Medical Center", style: TextStyle(color: Colors.grey)),
          ),
          Divider(color: Colors.grey),
          ListTile(
            title: Text("Physical Therapy", style: TextStyle(color: Colors.white)),
            subtitle: Text("Tomorrow, 10:00 AM - Wellness Center", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _emergencyButton(double width) {
    return Center(
      child: SizedBox(
        width: width * 0.9,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.warning_amber_outlined, color: Colors.white),
          label: const Text("Emergency SOS", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
