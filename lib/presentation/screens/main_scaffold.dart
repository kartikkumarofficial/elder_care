import 'package:elder_care/controllers/auth_controller.dart';
import 'package:elder_care/presentation/caregiver_dashboard.dart';
import 'package:elder_care/presentation/screens/location_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/nav_controller.dart';
import '../widgets/bottom_navigation_bar.dart';

import 'profile/profile_screen.dart';

class MainScaffold extends StatelessWidget {
  MainScaffold({super.key});

  final NavController navController = Get.find<NavController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    // Obx will rebuild the widget whenever the observable 'user' in AuthController changes.
    return Obx(() {
      // Show a loading spinner until the user data is fetched.
      if (authController.user.value == null) {
        return const Scaffold(
          backgroundColor: Color(0xFF121212),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Once user data is available, get the linkedUserId.
      // The '??' provides a fallback empty string if linkedUserId is null.
      final linkedUserId = authController.user.value?.linkedUserId ?? '';

      // Define the list of screens here, so it gets the latest linkedUserId.
      final List<Widget> screens = [
        CaregiverDashboardScreen(),
        // MainScaffold(),
        LocationScreen(linkedUserId: linkedUserId),
        Center(child: Text("Profile Screen",style: TextStyle(color: Colors.white),),)
      ];

      // Build the main scaffold with the correct data.
      return Scaffold(
        // This property allows the body to extend behind the navigation bar
        extendBody: true,
        backgroundColor: const Color(0xFF121212),
        body: screens[navController.selectedIndex.value],
        bottomNavigationBar: BottomNavBar(),
      );
    });
  }
}
