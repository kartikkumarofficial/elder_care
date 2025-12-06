import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';



class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    final user = authController.user.value;
    final h = Get.height;
    final w = Get.width;

    return Scaffold(
      backgroundColor: const Color(0xFF2A2E43),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: h * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: w * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: h * 0.03),

              // PROFILE CARD
              Container(
                padding: EdgeInsets.all(w * 0.05),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4E6C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: w * 0.12,
                      backgroundImage: user?.profileImage != null
                          ? NetworkImage(user!.profileImage!)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: user?.profileImage == null
                          ? Icon(Icons.person, size: w * 0.12, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? "Loading...",
                            style: TextStyle(
                              fontSize: w * 0.055,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            user?.email ?? "",
                            style: TextStyle(
                              fontSize: w * 0.038,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Role: ${user?.role ?? "Not selected"}",
                            style: TextStyle(
                              fontSize: w * 0.038,
                              color: Colors.tealAccent.shade100,
                            ),
                          ),
                          if (user?.careId != null) ...[
                            SizedBox(height: 6),
                            Text(
                              "Care ID: ${user!.careId}",
                              style: TextStyle(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w600,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ]
                        ],
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: h * 0.04),

              _sectionTitle("Account"),

              _menuTile(
                icon: Icons.person_outline,
                label: "Edit Profile",
                onTap: () {},
              ),

              _menuTile(
                icon: Icons.link,
                label: user?.role == "caregiver"
                    ? "Linked Care Receiver"
                    : "My Caregivers",
                onTap: () {},
              ),

              SizedBox(height: h * 0.03),

              _sectionTitle("Settings"),

              _menuTile(
                icon: Icons.privacy_tip_outlined,
                label: "Privacy & Security",
                onTap: () {},
              ),

              _menuTile(
                icon: Icons.help_outline,
                label: "Help & Support",
                onTap: () {},
              ),

              SizedBox(height: h * 0.05),

              // LOGOUT BUTTON
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    authController.logOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.25,
                      vertical: h * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  // Section Header
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Menu Tile UI
  Widget _menuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3C3F58),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.tealAccent, size: 26),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
        onTap: onTap,
      ),
    );
  }
}
