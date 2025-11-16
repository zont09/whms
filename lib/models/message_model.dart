class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final List<dynamic> attachments;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.attachments,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json["id"] ?? "",
      conversationId: json["conversation_id"] ?? "",
      senderId: json["sender_id"] ?? "",
      content: json["content"] ?? "",
      attachments: json["attachments"] ?? [],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "conversation_id": conversationId,
    "sender_id": senderId,
    "content": content,
    "attachments": attachments,
    "created_at": createdAt.toIso8601String(),
  };
}
