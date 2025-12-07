import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';

final AuthController authController = Get.find<AuthController>();

Widget socialButton(String label, String assetPath, double w, double h) {
  return Material(
    color: Colors.transparent, // required for InkWell
    borderRadius: BorderRadius.circular(w * 0.035),
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(w * 0.035),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(2, 3)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(w * 0.035),
        onTap: label=='Google'? authController.signInWithGoogle:authController.signInWithFacebook,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.012),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(assetPath, height: w * 0.06),
              SizedBox(width: w * 0.02),
              Text(
                label,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: w * 0.035),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
