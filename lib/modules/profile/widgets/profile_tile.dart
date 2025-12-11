import 'package:flutter/material.dart';

Widget ProfileTile({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin:   EdgeInsets.only(bottom: 12),
      padding:   EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style:   TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    ),
  );
}