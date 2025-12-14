import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elder_care/modules/care_receiver/views/schedule_screen.dart';

Widget buildScheduleCard({
  required double w,
  required double h,
  required String receiverId,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: w * 0.06),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Get.to(() => ScheduleScreen(

            // receiverIdOverride: receiverId,
          ));
        },
        child: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 36, color: Colors.teal),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Schedule",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "View tasks & events for today",
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}
