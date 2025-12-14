enum TimelineType { task, event }

class TimelineItem {
  final TimelineType type;

  // common
  final int id;
  final String title;
  final DateTime time;

  // task-only
  final bool alarmEnabled;

  // event-only
  final String? category;
  final String? notes;

  TimelineItem({
    required this.type,
    required this.id,
    required this.title,
    required this.time,
    this.alarmEnabled = false,
    this.category,
    this.notes,
  });
}
