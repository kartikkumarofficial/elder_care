import 'package:flutter/material.dart';


  Widget medicationTile(String name, String details) {
    return ListTile(
      leading: Icon(Icons.medication, color: Colors.blue),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(details),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
    );
  }

  Widget appointmentTile(String title, String details) {
    return ListTile(
      leading: Icon(Icons.calendar_today, color: Colors.blue),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(details),
    );
  }


Widget healthContainer(double srcWidth, String title, String value, IconData icon, Color iconColor) {
  return Container(
    width: (srcWidth - 48) / 2,
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(icon, size: 30.0, color: iconColor),
        const SizedBox(height: 8.0),
        Text(
          title,
          style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}


