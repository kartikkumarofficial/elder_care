// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/nav_controller.dart';


class BottomNavBar extends StatelessWidget {
  final NavController navController = Get.find();

  final List<IconData> icons = [
    Icons.home,
    // Icons.favorite,
    Icons.location_on,
    Icons.more_horiz,
  ];

  final List<String> labels = [
    'Home',
    'Location',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    var srcheight = MediaQuery.of(context).size.height;

    return Obx(() => Container(
      // height: srcheight * 0.1,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BottomNavigationBar(
        currentIndex: navController.selectedIndex.value,
        onTap: navController.changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: List.generate(labels.length, (index) {
          return BottomNavigationBarItem(
            icon: _buildIcon(index),
            label: labels[index],
          );
        }),
      ),
    ));
  }

  Widget _buildIcon(int index) {
    bool isSelected = navController.selectedIndex.value == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isSelected ? null : Colors.transparent,
      ),
      child: Icon(
        icons[index],
        color: isSelected ? Colors.white : Colors.grey,
        size: isSelected ? 28 : 24,
      ),
    );
  }
}
