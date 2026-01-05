enum TimelineType { task, event }

class TimelineItem {
  final TimelineType type;
  final int id;
  final String title;
  final DateTime time;
  final bool alarmEnabled;
  final bool isCompleted;

  TimelineItem({
    required this.type,
    required this.id,
    required this.title,
    required this.time,
    this.alarmEnabled = false,
    this.isCompleted = false,
  });

  TimelineItem copyWith({bool? isCompleted}) {
    return TimelineItem(
      type: type,
      id: id,
      title: title,
      time: time,
      alarmEnabled: alarmEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
