import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/care_link_controller.dart';

class RoleSelectionView extends StatefulWidget {
  @override
  _RoleSelectionViewState createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView> {
  final CareLinkController careLinkController = Get.find<CareLinkController>();
  final AuthController authController = Get.find<AuthController>();

  String selectedRole = ""; // caregiver / receiver

  @override
  Widget build(BuildContext context) {
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (authController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7AB7A7)),
          );
        }

        return Container(
          height: h,
          width: w,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/role2.png"),
              fit: BoxFit.cover,
              opacity: 0.12,
            ),
            gradient: LinearGradient(
              colors: [Color(0xFFeaf4f2), Color(0xFFfdfaf6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.08),
              child: Column(
                children: [
                  SizedBox(height: h * 0.17),

                  // //header image
                  // Image.asset(
                  //   "assets/images/role.jpg",
                  //   height: h * 0.22,
                  //   fit: BoxFit.contain,
                  // ),

                  SizedBox(height: h * 0.03),

                  /// TITLE
                  Text(
                    "Choose Your Role",
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.075,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: h * 0.01),

                  Text(
                    "Choose the role that feels right for you.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.043,
                      color: Colors.black54,
                    ),
                  ),

                  SizedBox(height: h * 0.05),

                  /// ROLE CARDS WRAPPED IN A CARD PANEL
                  Card(
                    elevation: 10,
                    color: Colors.white.withOpacity(0.92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.06),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: h * 0.035,
                        horizontal: w * 0.05,
                      ),
                      child: Column(
                        children: [
                          /// CAREGIVER CARD
                          _roleCard(
                            title: "Caregiver",
                            subtitle: "I want to support a loved one.",
                            icon: Icons.volunteer_activism,
                            color: const Color(0xFF7AB7A7),
                            value: "caregiver",
                            w: w,
                            h: h,
                          ),

                          SizedBox(height: h * 0.03),

                          /// CARE COMPANION CARD
                          _roleCard(
                            title: "Care Companion",
                            subtitle: "I'm here to stay connected and supported.",
                            icon: Icons.elderly,
                            color: Colors.teal.shade300,
                            value: "receiver",
                            w: w,
                            h: h,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.04),

                  /// CONTINUE BUTTON (only visible when selected)
                  AnimatedOpacity(
                    opacity: selectedRole.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: selectedRole.isEmpty
                        ? const SizedBox.shrink()
                        : ElevatedButton(
                      onPressed: () async {
                        await authController.updateUserRoleAndNavigate(selectedRole);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7AB7A7),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, h * 0.065),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.04),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        "Continue",
                        style: GoogleFonts.nunito(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: h * 0.06),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// ROLE CARD BUILDER
  Widget _roleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String value,
    required double w,
    required double h,
  }) {
    final bool isSelected = selectedRole == value;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(vertical: h * 0.025, horizontal: w * 0.04),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.22) : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(w * 0.05),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(w * 0.035),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.25),
              ),
              child: Icon(icon, color: color, size: w * 0.09),
            ),
            SizedBox(width: w * 0.05),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.048,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: w * 0.033,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
