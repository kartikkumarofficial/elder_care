import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/nav_controller.dart';

class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  final NavController nav = Get.find<NavController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        height: Get.height*0.115,
        padding: const EdgeInsets.only(bottom: 13, left: 26,right: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home_outlined, "Home", 0),
            _navItem(Icons.chat_bubble_outline, "Chat", 1),
            _navItem(Icons.location_on_outlined, "Location", 2),
            _navItem(Icons.person_outline, "Profile", 3),
          ],
        ),
      );
    });
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = nav.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => nav.selectedIndex.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 22 : 16, // wider pills
          vertical: isSelected ? 14 : 10,   // taller pills
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8EDFF) // light blue highlight
              : const Color(0xFFF2F3F7), // soft grey bubbles
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: isSelected ? 28 : 24, // larger icons
              color: isSelected ? const Color(0xFF1E2A78) : Colors.black54,
            ),

            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16, // bigger text
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2A78),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
