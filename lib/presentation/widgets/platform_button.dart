import 'package:flutter/material.dart';

Widget  PlatformIcon(IconData icon, String name, bool isConnected) {
  return Container(
    margin:   EdgeInsets.only(right: 12),
    padding:   EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(
        color: isConnected ? Colors.green : Colors.grey.shade600,
        width: 1.2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: isConnected ? Colors.green : Colors.grey),
        SizedBox(width: 8),
        Text(
          name,
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}