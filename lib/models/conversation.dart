class Conversation {
  const Conversation({
    required this.id,
    required this.participantName,
    this.lastMessage,
    this.updatedAt,
    this.unreadCount = 0,
  });

  final String id;
  final String participantName;
  final String? lastMessage;
  final DateTime? updatedAt;
  final int unreadCount;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: (json['id'] ?? '').toString(),
      participantName: (json['participant_name'] ?? 'Unknown').toString(),
      lastMessage: json['last_message']?.toString(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      unreadCount: int.tryParse((json['unread_count'] ?? '0').toString()) ?? 0,
    );
  }
}
