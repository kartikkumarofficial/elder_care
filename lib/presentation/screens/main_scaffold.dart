import 'package:elder_care/presentation/caregiver_dashboard.dart';
import 'package:elder_care/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/nav_controller.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../screens/home_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/profile_screen.dart';

class MainScaffold extends StatelessWidget {
  MainScaffold({super.key});

  final NavController navController = Get.put(NavController());

  final List<Widget> screens = [
    CaregiverDashboardScreen(),
    // HomeScreen(),
    TasksScreen(),
    EmergencyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Color(0xFF121212),
      body: screens[navController.selectedIndex.value],
      bottomNavigationBar: BottomNavBar(),
    ));
  }
}
