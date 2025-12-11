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

  return Padding(
    padding: EdgeInsets.only(left: Get.width * 0.05),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "HEALTH STATUS",
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 14),

        // 🔥 Scrollable section only around the row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child: Row(
            children: [
              healthCard(
                icon: Icons.favorite,
                iconColor: Colors.redAccent,
                label: "Heart Rate",
                value: hr,
                gradient: [
                  Colors.redAccent.withOpacity(0.18),
                  Colors.redAccent.withOpacity(0.08),
                ],
              ),
              const SizedBox(width: 12),

              healthCard(
                icon: Icons.warning_amber_rounded,
                iconColor: controller.fallDetected.value ? Colors.orange : Colors.green,
                label: "Fall",
                value: controller.fallDetected.value ? "Fall Detected" : "No Fall",
                gradient: [
                  Colors.orange.withOpacity(0.18),
                  Colors.orange.withOpacity(0.08),
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
                  Colors.deepPurple.withOpacity(0.18),
                  Colors.deepPurple.withOpacity(0.08),
                ],
              ),
              const SizedBox(width: 12),

              healthCard(
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blueAccent,
                label: "Oxygen",
                value: oxy,
                gradient: [
                  Colors.blueAccent.withOpacity(0.18),
                  Colors.blueAccent.withOpacity(0.08),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
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
    width: Get.width * 0.32,   // matches your exact current look but ensures overflow
    // auto responsive
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradient,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // icon chip
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),

        const SizedBox(height: 12),

        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}