class EventModel {
  final int? id;
  final String title;
  final DateTime eventTime;
  final String category;
  final String notes;
  final String receiverId;

  EventModel({
    this.id,
    required this.title,
    required this.eventTime,
    required this.category,
    required this.notes,
    required this.receiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'event_time': eventTime.toUtc().toIso8601String(),
      'category': category,
      'notes': notes,
      'receiver_id': receiverId,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'] ?? '',
      eventTime: DateTime.parse(map['event_time']),
      category: map['category'] ?? 'General',
      notes: map['notes'] ?? '',
      receiverId: map['receiver_id'],
    );
  }
}