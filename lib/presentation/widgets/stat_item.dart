import 'package:flutter/material.dart';

Widget StatItem(String title, String value) {
  return Column(
    children: [
      Text(value,
          style:   TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
      SizedBox(height: 4),
      Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
    ],
  );
}