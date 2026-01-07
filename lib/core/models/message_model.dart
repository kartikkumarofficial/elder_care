class MessageModel {
  final int id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isSeen;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.isSeen,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      isSeen: json['is_seen'] == true, // ✅ CRITICAL: null-safe
    );
  }
}
