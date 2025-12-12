import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/caregiver_dashboard_controller.dart';
final controller = Get.put(CaregiverDashboardController());

Widget healthStatusSection() {
  final hr = controller.heartRate.value == "--"
      ? "--"
      : "${controller.heartRate.value} bpm";

  final oxy = controller.oxygen.value == "--"
      ? "--"
      : "${controller.oxygen.value}%";

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: Text(
          "HEALTH STATUS",
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),

      const SizedBox(height: 14),

      /// FIX: No left gap, same as events card scroll
      SizedBox(
        height: 115, // shorter height
        child: ListView(
          padding: EdgeInsets.only(left: Get.width * 0.05),
          scrollDirection: Axis.horizontal,
          children: [
            healthCard(
              icon: Icons.favorite,
              iconColor: Colors.redAccent,
              label: "Heart Rate",
              value: hr,
              gradient: [
                Colors.redAccent.withOpacity(0.15),
                Colors.redAccent.withOpacity(0.05),
              ],
            ),
            const SizedBox(width: 12),

            healthCard(
              icon: Icons.warning_amber_rounded,
              iconColor:
              controller.fallDetected.value ? Colors.orange : Colors.green,
              label: "Fall",
              value: controller.fallDetected.value
                  ? "Fall Detected"
                  : "No Fall",
              gradient: [
                Colors.orange.withOpacity(0.15),
                Colors.orange.withOpacity(0.05),
              ],
            ),
            const SizedBox(width: 12),

            healthCard(
              icon: Icons.directions_walk,
              iconColor: Colors.deepPurple,
              label: "Steps",
              value: controller.steps.value == "--"
                  ? "--"
                  : controller.steps.value.toString(),
              gradient: [
                Colors.deepPurple.withOpacity(0.15),
                Colors.deepPurple.withOpacity(0.05),
              ],
            ),
            const SizedBox(width: 12),

            healthCard(
              icon: Icons.water_drop_rounded,
              iconColor: Colors.blueAccent,
              label: "Oxygen",
              value: oxy,
              gradient: [
                Colors.blueAccent.withOpacity(0.15),
                Colors.blueAccent.withOpacity(0.05),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget healthCard({
  required IconData icon,
  required Color iconColor,
  required String label,
  required String value,
  required List<Color> gradient,
}) {
  return Container(
    width: Get.width * 0.28,  // wider rectangular card
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: iconColor),

        const SizedBox(height: 10),

        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  );
}
