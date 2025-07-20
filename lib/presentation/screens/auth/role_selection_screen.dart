// presentation/screens/auth/role_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart'; // Make sure this path is correct

class RoleSelectionView extends StatelessWidget {
  // FIX: Find the existing AuthController instance instead of creating a new one
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2E43),
      // FIX: Wrap with Obx to show a loading indicator
      body: Obx(() => authController.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select Your Role",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              // FIX: Call the new method in AuthController
              onPressed: () => authController.updateUserRoleAndNavigate("caregiver"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4E6C),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16)
              ),
              child: const Text("I'm a Caregiver"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // FIX: Call the new method in AuthController
              onPressed: () => authController.updateUserRoleAndNavigate("receiver"), // Changed from "careseeker"
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4E6C),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16)
              ),
              child: const Text("I Need Care"),
            ),
          ],
        ),
      ),
      ),
    );
  }
}