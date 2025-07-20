import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2A2E43),
      body: Obx(
            () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
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
                      Text(
                        "Welcome back, ${controller.userName}",
                        style: TextStyle(
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
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
              SizedBox(height: 20),
              _sectionTitle("Health Overview"),
              SizedBox(height: 12),
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
              SizedBox(height: 24),
              _sectionTitle("Reminders"),
              SizedBox(height: 8),
              _remindersSection(controller, width),
              SizedBox(height: 24),
              _sectionTitle("Location"),
              SizedBox(height: 8),
              _locationSection(width),
              SizedBox(height: 24),
              _sectionTitle("Appointments"),
              SizedBox(height: 8),
              _appointmentsSection(),
              SizedBox(height: 24),
              _emergencyButton(width),
              SizedBox(height: 24),
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
            color: Colors.white ));
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
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ],
          )
        ],
      ),
    );
  }

  Widget _remindersSection(DashboardController controller, double width) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E6C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...controller.medications.map((med) => ListTile(
            title: Text(med.name, style: TextStyle(color: Colors.white)),
            subtitle: Text(med.time, style: TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => controller.deleteMedication(med),
            ),
          )),
          TextButton.icon(
            onPressed: controller.showAddMedicationBottomSheet,
            icon: Icon(Icons.add, color: Colors.blueAccent),
            label: Text("Add Reminder", style: TextStyle(color: Colors.blueAccent)),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset('assets/images/map.png', fit: BoxFit.contain)),
          ListTile(
            title: Text("Last updated: 2 mins ago", style: TextStyle(color: Colors.grey)),
            trailing: TextButton(
              onPressed: () {},
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
        children: [
          ListTile(
            title: Text("Dr. Smith - Cardiology", style: TextStyle(color: Colors.white)),
            subtitle: Text("Today, 2:30 PM - Medical Center", style: TextStyle(color: Colors.grey)),
          ),
          Divider(color: Colors.grey[700]),
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
          icon: Icon(Icons.warning_amber_outlined, color: Colors.white),
          label: Text("Emergency SOS", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}