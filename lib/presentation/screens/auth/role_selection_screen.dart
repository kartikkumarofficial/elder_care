import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';

class RoleSelectionView extends StatelessWidget {
  final controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2A2E43),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select Your Role",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.updateRole("caregiver"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A4E6C),
              ),
              child: const Text("I'm a Caregiver"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => controller.updateRole("receiver"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A4E6C),
              ),
              child: const Text("I'm a Receiver"),
            ),
          ],
        ),
      ),
    );
  }
}
