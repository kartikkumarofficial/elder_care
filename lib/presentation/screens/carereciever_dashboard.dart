import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/carereceiver_dashboard_controller.dart';
import '../../models/task_model.dart';

class CareReceiverDashboard extends StatefulWidget {


  CareReceiverDashboard({Key? key}) : super(key: key);

  @override
  State<CareReceiverDashboard> createState() => _CareReceiverDashboardState();
}

class _CareReceiverDashboardState extends State<CareReceiverDashboard> {


  final CareReceiverDashboardController controller = Get.put(CareReceiverDashboardController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2E43),
      body: RefreshIndicator(
        // FIX: This now calls the new method to restart the controller's logic.
        onRefresh: () => controller.refreshAllData(),
        child: Obx(
              () => controller.isLoading.value && controller.userName.value.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // Ensures refresh works even if content is small
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildLocationStatusCard(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Health Vitals"),
                  const SizedBox(height: 16),
                  _buildHealthVitalsGrid(context),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Reminders"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSosBar(),
    );
  }

  Widget _buildLocationStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E6C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
            () => Row(
          children: [
            Icon(
              controller.isSharingLocation.value ? Icons.my_location : Icons.location_disabled,
              color: controller.isSharingLocation.value ? Colors.greenAccent : Colors.redAccent,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Location Sharing",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.locationStatusMessage.value,
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
          "Welcome, ${controller.userName.value}",
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        )),
        const SizedBox(height: 8),
        Obx(() => Text(
          "Your Care ID: ${authController.user.value?.careId ?? 'Loading...'}",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        )
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildHealthVitalsGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _healthCard(width, "Heart Rate", "75 BPM", Icons.favorite, Colors.red),
        _healthCard(width, "BP", "120/80", Icons.bloodtype, Colors.purple),
        _healthCard(width, "Sugar", "95 mg/dL", Icons.water_drop, Colors.teal),
        _healthCard(width, "Steps", "2,450", Icons.directions_walk, Colors.orange),
      ],
    );
  }

  Widget _healthCard(double width, String title, String value, IconData icon, Color color) {
    return Container(
      width: (width - 44) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4E6C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ])
      ]),
    );
  }





  Widget _buildBottomSosBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.warning_amber_rounded, size: 28),
        label: const Text("EMERGENCY SOS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        onPressed: () {
          authController.logOut();

          Get.snackbar("SOS", "Emergency alert sent to caregiver!", backgroundColor: Colors.red, colorText: Colors.white);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}


