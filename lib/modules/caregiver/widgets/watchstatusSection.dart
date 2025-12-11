import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/caregiver_dashboard_controller.dart';


final controller = Get.put(CaregiverDashboardController());
Widget watchStatusSection() {
  return Obx(() {
    final connected = controller.fitbitConnected.value;
    final battery = controller.battery.value;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
      child: Row(
        children: [
          // -------- Wearable Status --------
          Flexible(
            child: Row(
              children: [
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

                // Make text wrap if needed (prevents overflow)
                Expanded(
                  child: Text(
                    connected ? "Wearable Connected" : "No Wearable Detected",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // -------- Battery --------
          Row(
            children: [
              Icon(
                Icons.battery_full,
                size: 20,
                color: battery > 40 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                "$battery%",
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // -------- Refresh Button (more compact) --------
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
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Refreshing...",
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                )
                    : Text(
                  "Refresh",
                  style: GoogleFonts.nunito(
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