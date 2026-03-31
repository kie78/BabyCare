class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.createdAt,
    this.senderName,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime? createdAt;
  final String? senderName;

  factory Message.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderMap = sender is Map<String, dynamic>
        ? sender
        : <String, dynamic>{};
    final messagePayload = json['message'];
    final messageMap = messagePayload is Map<String, dynamic>
        ? messagePayload
        : <String, dynamic>{};

    DateTime? parseTimestamp(List<dynamic> values) {
      for (final value in values) {
        final raw = (value ?? '').toString().trim();
        if (raw.isEmpty) {
          continue;
        }
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) {
          return parsed;
        }
      }
      return null;
    }

    return Message(
      id: (json['id'] ?? messageMap['id'] ?? '').toString(),
      conversationId:
          (json['conversation_id'] ?? messageMap['conversation_id'] ?? '')
              .toString(),
      senderId: (json['sender_id'] ??
              messageMap['sender_id'] ??
              senderMap['id'] ??
              senderMap['user_id'] ??
              '')
          .toString(),
      content: (json['content'] ??
              json['text'] ??
              json['body'] ??
              messageMap['content'] ??
              messageMap['message'] ??
              messageMap['text'] ??
              messageMap['body'] ??
              (messagePayload is String ? messagePayload : ''))
          .toString(),
      createdAt: parseTimestamp([
        json['created_at'],
        json['sent_at'],
        json['timestamp'],
        json['updated_at'],
        messageMap['created_at'],
        messageMap['sent_at'],
        messageMap['timestamp'],
        messageMap['updated_at'],
      ]),
      senderName:
          (json['sender_name'] ??
                  messageMap['sender_name'] ??
                  senderMap['full_name'] ??
                  senderMap['name'])
              ?.toString(),
    );
  }
}
