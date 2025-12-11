  // lib/presentation/widgets/tasks/task_model.dart
  import 'package:meta/meta.dart';

  class TaskModel {
    final int? id;
    final String receiverId; // uuid stored as String
    final String title;
    final String? datetime; // ISO string, optional
    final bool alarmEnabled;
    final String? createdAt; // ISO string

    TaskModel({
      this.id,
      required this.receiverId,
      required this.title,
      this.datetime,
      this.alarmEnabled = false,
      this.createdAt,
    });

    Map<String, dynamic> toMap() {
      return {
        if (id != null) 'id': id,
        'receiver_id': receiverId,
        'title': title,
        'datetime': datetime,
        'alarm_enabled': alarmEnabled,
        'created_at': createdAt,
      };
    }
    Map<String, dynamic> toUpdateMap() {
      return {
        'receiver_id': receiverId,
        'title': title,
        'datetime': datetime,
        'alarm_enabled': alarmEnabled,
      };
    }


    factory TaskModel.fromMap(Map<String, dynamic> m) {
      return TaskModel(
        id: m['id'] is int ? m['id'] as int : (m['id'] is num ? (m['id'] as num).toInt() : null),
        receiverId: (m['receiver_id'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        datetime: m['datetime'] == null ? null : m['datetime'].toString(),
        alarmEnabled: m['alarm_enabled'] == null
            ? false
            : (m['alarm_enabled'] is bool
            ? m['alarm_enabled'] as bool
            : (m['alarm_enabled'].toString().toLowerCase() == 'true')),
        createdAt: m['created_at'] == null ? null : m['created_at'].toString(),
      );
    }
  }
