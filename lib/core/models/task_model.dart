import 'package:meta/meta.dart';

@immutable
class TaskModel {
  final int? id;
  final String receiverId; // uuid as String
  final String title;
  final String? datetime; // ISO string
  final bool alarmEnabled;
  final bool vibrate;
  final String repeatType;        // none | daily | weekly | custom
  final List<String> repeatDays;  // ['mon','wed']
  final bool isCompleted;         // ✅ NEW
  final String? createdAt;        // ISO string

  const TaskModel({
    this.id,
    required this.receiverId,
    required this.title,
    this.datetime,
    this.alarmEnabled = false,
    this.vibrate = false,
    this.repeatType = 'none',
    this.repeatDays = const [],
    this.isCompleted = false,
    this.createdAt,
  });

  // ─────────────────────────────────────────────
  // INSERT MAP
  // ─────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'receiver_id': receiverId,
      'title': title,
      'datetime': datetime,
      'alarm_enabled': alarmEnabled,
      'vibrate': vibrate,
      'repeat_type': repeatType,
      'repeat_days': repeatDays,
      'is_completed': isCompleted,
      'created_at': createdAt,
    };
  }

  // ─────────────────────────────────────────────
  // UPDATE MAP
  // ─────────────────────────────────────────────

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'datetime': datetime,
      'alarm_enabled': alarmEnabled,
      'vibrate': vibrate,
      'repeat_type': repeatType,
      'repeat_days': repeatDays,
      'is_completed': isCompleted,
    };
  }

  // ─────────────────────────────────────────────
  // FROM DB
  // ─────────────────────────────────────────────

  factory TaskModel.fromMap(Map<String, dynamic> m) {
    return TaskModel(
      id: m['id'] is int
          ? m['id'] as int
          : (m['id'] is num ? (m['id'] as num).toInt() : null),

      receiverId: (m['receiver_id'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),

      datetime:
      m['datetime'] == null ? null : m['datetime'].toString(),

      alarmEnabled: m['alarm_enabled'] is bool
          ? m['alarm_enabled'] as bool
          : m['alarm_enabled']?.toString().toLowerCase() == 'true',

      vibrate: m['vibrate'] ?? false,

      repeatType: m['repeat_type'] ?? 'none',
      repeatDays:
      List<String>.from(m['repeat_days'] ?? const []),

      isCompleted: m['is_completed'] ?? false,

      createdAt:
      m['created_at'] == null ? null : m['created_at'].toString(),
    );
  }

  // ─────────────────────────────────────────────
  // COPY WITH (OPTIONAL BUT USEFUL)
  // ─────────────────────────────────────────────

  TaskModel copyWith({
    String? title,
    String? datetime,
    bool? alarmEnabled,
    bool? vibrate,
    String? repeatType,
    List<String>? repeatDays,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      receiverId: receiverId,
      title: title ?? this.title,
      datetime: datetime ?? this.datetime,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      vibrate: vibrate ?? this.vibrate,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
