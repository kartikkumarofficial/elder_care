import 'package:elder_care/modules/care_receiver/views/carereciever_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CareIdDisplayScreen extends StatelessWidget {
  final String careId;

  const CareIdDisplayScreen({Key? key, required this.careId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,

      body: Container(
        height: h,
        width: w,

        /// SAME CREAMISH THEME + BG IMAGE AS LOGIN SCREEN
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/auth/login_bg.png"),
            fit: BoxFit.cover,
            opacity: 0.12,
          ),
          gradient: LinearGradient(
            colors: [Color(0xFFeaf4f2), Color(0xFFfdfaf6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        padding: EdgeInsets.symmetric(horizontal: w * 0.08),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO (same style as login)
            Image.asset(
              'assets/images/eldercare_logo.png',
              height: h * 0.17,
            ),
            SizedBox(height: h * 0.015),

            Text(
              "Your Unique Care ID",
              style: GoogleFonts.nunito(
                fontSize: w * 0.07,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: h * 0.01),

            Text(
              "Share this ID with your caregiver to link your account.",
              style: GoogleFonts.nunito(
                fontSize: w * 0.04,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: h * 0.05),

            /// CARD — SAME STYLE AS LOGIN CARD
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: careId));
                Get.snackbar("Copied!", "Care ID copied to clipboard.",
                    snackPosition: SnackPosition.BOTTOM);
              },

              child: Card(
                elevation: 12,
                shadowColor: Colors.black26,
                color: Colors.white.withAlpha(120),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.06),
                ),

                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.1,
                    vertical: h * 0.035,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        careId,
                        style: GoogleFonts.nunito(
                          fontSize: w * 0.09,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7AB7A7), // MATCH LOGIN THEME
                          letterSpacing: 4,
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      Icon(Icons.copy,
                          color: Colors.grey.shade600, size: w * 0.065)
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: h * 0.06),

            /// BUTTON (SAME STYLE AS LOGIN BUTTON)
            SizedBox(
              width: double.infinity,
              height: h * 0.065,
              child: ElevatedButton(
                onPressed: () => Get.offAll(() => ReceiverDashboardScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF7AB7A7),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  textStyle: GoogleFonts.nunito(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.04),
                  ),
                ),
                child: Text("Continue to Dashboard"),
              ),
            ),

            SizedBox(height: h * 0.04),
          ],
        ),
      ),
    );
  }
}
