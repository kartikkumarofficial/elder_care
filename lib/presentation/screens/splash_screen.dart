import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This line starts the SplashController's logic as soon as the screen is built.
    Get.put(SplashController());

    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your app logo here
            // Image.asset('assets/logo.png', width: 150),
            // SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 15),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
