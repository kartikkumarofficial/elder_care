import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/carereceiver_dashboard_controller.dart';

Widget moodSection(double w, double h) {
  final ReceiverDashboardController controller =
      Get.find<ReceiverDashboardController>();
  final moods = {
    'very_sad': '😣',
    'sad': '😔',
    'neutral': '😐',
    'happy': '😃',
    'very_happy': '😄',
  };

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.05),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7AB7A7).withOpacity(0.18),
            Colors.white.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF7AB7A7).withOpacity(0.25)),
      ),
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How are you feeling right now?",
            style: GoogleFonts.nunito(
              fontSize: w * 0.045,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: h * 0.02),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: moods.entries.map((e) {
                final selected = controller.selectedMood.value == e.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(w * 0.028),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF7AB7A7).withOpacity(0.35)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: () => controller.submitMood(e.key),
                    child: Text(e.value, style: TextStyle(fontSize: w * 0.085)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
