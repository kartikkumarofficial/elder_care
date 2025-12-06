import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/care_link_controller.dart'; // Adjust path if needed

class CareLinkScreen extends StatelessWidget {
  CareLinkScreen({Key? key}) : super(key: key);

  final CareLinkController controller = Get.find<CareLinkController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2E43),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(
                () => controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.link, color: Colors.white, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Link to a Care Receiver',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter the 6-digit Care ID provided by the person you'll be caring for.",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Form(
                  child: TextFormField(
                    controller: controller.careIdController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, color: Colors.white, letterSpacing: 8),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: '______',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: controller.linkToReceiver,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Link Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
