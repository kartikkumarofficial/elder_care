import 'package:flutter/material.dart';

class Task {
  final int id;
  final String title;
  final TimeOfDay time;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  /// Creates a Task object from a JSON map.
  /// This factory is now more robust to prevent crashes from null data.
  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay parsedTime;
    final timeString = json['task_time'] as String?;

    // Safely parse the time, defaulting to midnight if it's missing or malformed.
    if (timeString != null && timeString.contains(':')) {
      final timeParts = timeString.split(':');
      parsedTime = TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 0,
        minute: int.tryParse(timeParts[1]) ?? 0,
      );
    } else {
      parsedTime = const TimeOfDay(hour: 0, minute: 0);
    }

    return Task(
      // Default to 0 if 'id' is null
      id: json['id'] ?? 0,
      // Default to a placeholder title if 'task_title' is null
      title: json['task_title'] ?? 'Untitled Task',
      // Use the safely parsed time
      time: parsedTime,
      // Default to false if 'is_completed' is null
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
