import 'package:flutter/material.dart';

import '../../controllers/nav_controller.dart';


class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.navController,
  });

  final NavController navController;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E1E1E),
      currentIndex: navController.selectedIndex.value,
      onTap: navController.changeTab,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 14,
      unselectedFontSize: 12,
      iconSize: 28,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}