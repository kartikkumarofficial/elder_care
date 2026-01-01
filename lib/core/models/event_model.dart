class EventModel {
  final int? id;
  final String title;
  final String datetime; // ISO string of combined date+time
  final String category;
  final String notes;

  EventModel({
    this.id,
    required this.title,
    required this.datetime,
    required this.category,
    required this.notes,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'date': datetime,
    'category': category,
    'notes': notes,
  };

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] is int
          ? map['id']
          : (map['id'] is num ? (map['id'] as num).toInt() : null),
      title: (map['title'] ?? '').toString(),
      datetime: (map['date'] ?? '').toString(),
      category: (map['category'] ?? 'General').toString().trim(),
      notes: (map['notes'] ?? '').toString(),
    );
  }
}
