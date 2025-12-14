


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/carereceiver_dashboard_controller.dart';

final ReceiverDashboardController controller = Get.find<ReceiverDashboardController>();
Widget sosButton(double w, double h) {
  return Padding(
    padding:  EdgeInsets.symmetric(horizontal: w*0.05),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.sendSOS,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          minimumSize: Size(double.infinity, h * 0.065),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(w * 0.045),
          ),
          elevation: 6,
        ),
        child: Text(
          "SOS EMERGENCY",
          style: GoogleFonts.nunito(
            fontSize: w * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}