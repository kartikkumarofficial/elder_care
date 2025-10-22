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
                  const SizedBox(height: 16),
                  _buildRemindersList(context),
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
          "Care ID: ${controller.careId.value}",
          style: TextStyle(fontSize: 16, color: Colors.grey[400], fontWeight: FontWeight.w500),
        )),
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

  Widget _buildRemindersList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF4A4E6C), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Obx(() => controller.tasks.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No reminders for today.", style: TextStyle(color: Colors.white70)),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return _TaskTile(task: task, controller: controller);
            },
          )),
          TextButton.icon(
            onPressed: () => _showAddTaskDialog(context),
            icon: const Icon(Icons.add, color: Colors.blueAccent),
            label: const Text("Add Reminder", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    TimeOfDay? selectedTime;
    final Rx<TimeOfDay?> reactiveTime = Rx<TimeOfDay?>(null);
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF3C3F58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add a New Reminder", style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Reminder Name",
              labelStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => ActionChip(
            avatar: const Icon(Icons.alarm, color: Colors.white),
            label: Text(
              reactiveTime.value == null ? "Pick Time" : reactiveTime.value!.format(context),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
            onPressed: () async {
              selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (selectedTime != null) reactiveTime.value = selectedTime;
            },
          ))
        ]),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel", style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && selectedTime != null) {
                controller.addTask(titleController.text, selectedTime!);
                Get.back();
              } else {
                Get.snackbar("Error", "Please provide a title and time.", backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
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

class _TaskTile extends StatelessWidget {
  final Task task;
  final CareReceiverDashboardController controller;
  const _TaskTile({required this.task, required this.controller});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();
    final formattedTime = timeFormat.format(DateTime(2023, 1, 1, task.time.hour, task.time.minute));
    return ListTile(
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          color: task.isCompleted ? Colors.grey[500] : Colors.white,
        ),
      ),
      subtitle: Text(formattedTime, style: TextStyle(color: Colors.grey[400])),
      trailing: Checkbox(
        value: task.isCompleted,
        onChanged: (bool? newValue) {
          if (newValue != null) controller.toggleTaskCompletion(task.id, newValue);
        },
        activeColor: Colors.green,
        checkColor: Colors.white,
        side: BorderSide(color: Colors.grey[600]!),
      ),
    );
  }
}
