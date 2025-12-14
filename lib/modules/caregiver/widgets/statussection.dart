import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/caregiver_dashboard_controller.dart';

final controller = Get.put(CaregiverDashboardController());

Widget StatusSection() {
  return Obx(() {
    final mood = controller.receiverMood.value;
    final hasMood = controller.moodAvailable.value;

    final battery = controller.battery.value;
    final charging = controller.isCharging.value;
    final connected = controller.fitbitConnected.value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
      child: Row(
        children: [
          // ================= LEFT : MOOD =================
          Expanded(
            child: Row(
              children: [
                Text(
                  _emojiOnlyForMood(mood, hasMood),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 6),
                Text(
                  _labelForMood(mood, hasMood),
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ================= WEARABLE ICON (UNCHANGED STYLE) =================
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? Colors.teal.shade100 : Colors.red.shade100,
            ),
            child: Icon(
              connected ? Icons.watch : Icons.watch_off,
              color: connected ? Colors.teal.shade700 : Colors.red.shade700,
              size: 18,
            ),
          ),

          const SizedBox(width: 8),

          // ================= BATTERY (OLD BEHAVIOR KEPT) =================
          Row(
            children: [
              Icon(
                charging
                    ? Icons.battery_charging_full
                    : Icons.battery_full,
                size: 20,
                color: battery > 40 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                "$battery%",
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // ================= REFRESH (UNCHANGED) =================
          SizedBox(
            height: 32,
            child: Obx(() {
              final refreshing = controller.isRefreshing.value;

              return OutlinedButton(
                onPressed: refreshing ? null : controller.refreshData,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade300, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: refreshing
                    ? SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue.shade700,
                  ),
                )
                    : Text(
                  "Refresh",
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  });
}

// ================= HELPERS =================

String _labelForMood(String mood, bool hasMood) {
  if (!hasMood) return "Mood not updated";

  switch (mood) {
    case "very_happy":
      return "Feeling great";
    case "happy":
      return "Feeling good";
    case "neutral":
      return "Feeling okay";
    case "sad":
      return "Feeling low";
    case "very_sad":
      return "Feeling very low";
    default:
      return "Feeling okay";
  }
}

String _emojiOnlyForMood(String mood, bool hasMood) {
  if (!hasMood) return "😐";

  switch (mood) {
    case "very_happy":
      return "😄";
    case "happy":
      return "🙂";
    case "neutral":
      return "😐";
    case "sad":
      return "🙁";
    case "very_sad":
      return "😢";
    default:
      return "😐";
  }
}
