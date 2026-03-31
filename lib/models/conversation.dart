class Conversation {
  const Conversation({
    required this.id,
    required this.participantName,
    this.lastMessage,
    this.updatedAt,
    this.unreadCount = 0,
    this.participantRole,
    this.participantOccupation,
    this.participantId,
    this.participantPhone,
    this.profileImageUrl,
    this.lastSenderId,
    this.isRead,
    this.isLocked,
  });

  final String id;
  final String participantName;
  final String? lastMessage;
  final DateTime? updatedAt;
  final int unreadCount;
  final String? participantRole;
  final String? participantOccupation;
  final String? participantId;
  final String? participantPhone;
  final String? profileImageUrl;
  final String? lastSenderId;
  final bool? isRead;
  final bool? isLocked;

  Conversation copyWith({
    String? id,
    String? participantName,
    String? lastMessage,
    DateTime? updatedAt,
    int? unreadCount,
    String? participantRole,
    String? participantOccupation,
    String? participantId,
    String? participantPhone,
    String? profileImageUrl,
    String? lastSenderId,
    bool? isRead,
    bool? isLocked,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantName: participantName ?? this.participantName,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      participantRole: participantRole ?? this.participantRole,
      participantOccupation: participantOccupation ?? this.participantOccupation,
      participantId: participantId ?? this.participantId,
      participantPhone: participantPhone ?? this.participantPhone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      isRead: isRead ?? this.isRead,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  bool hasUnreadFor(String? currentUserId) {
    final normalizedCurrentUserId = (currentUserId ?? '').trim();
    final normalizedLastSenderId = (lastSenderId ?? '').trim();

    if (isRead != null && normalizedLastSenderId.isNotEmpty) {
      return !isRead! && normalizedLastSenderId != normalizedCurrentUserId;
    }

    return unreadCount > 0;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'];
    final participantMap = participant is Map<String, dynamic>
        ? participant
        : <String, dynamic>{};
    final babysitter = json['babysitter'];
    final babysitterMap = babysitter is Map<String, dynamic>
        ? babysitter
        : <String, dynamic>{};
    final parent = json['parent'];
    final parentMap = parent is Map<String, dynamic>
        ? parent
        : <String, dynamic>{};
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
    final lastMessagePayload = json['last_message'];
    final recentMessagePayload = json['recent_message'];
    final lastMessageMap = lastMessagePayload is Map<String, dynamic>
        ? lastMessagePayload
        : <String, dynamic>{};
    final recentMessageMap = recentMessagePayload is Map<String, dynamic>
        ? recentMessagePayload
        : <String, dynamic>{};

    String fallbackString(List<dynamic> values, {String fallback = ''}) {
      for (final value in values) {
        if (value is Map<String, dynamic>) {
          final nestedText = fallbackString([
            value['content'],
            value['message'],
            value['text'],
            value['body'],
          ]);
          if (nestedText.isNotEmpty) {
            return nestedText;
          }
          continue;
        }
        final text = (value ?? '').toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return fallback;
    }

    return Conversation(
      id: fallbackString([json['id'], json['conversation_id']], fallback: ''),
      participantName: fallbackString([
        json['participant_name'],
        json['other_participant_name'],
        json['other_user_name'],
        json['babysitter_name'],
        json['parent_name'],
        json['name'],
        participantMap['full_name'],
        participantMap['name'],
        participantMap['display_name'],
        babysitterMap['full_name'],
        babysitterMap['name'],
        parentMap['full_name'],
        parentMap['name'],
        userMap['full_name'],
        userMap['name'],
        json['full_name'],
      ], fallback: 'Unknown'),
      lastMessage: fallbackString([
        json['preview_text'],
        json['last_message'],
        json['recent_message'],
        json['last_message_preview'],
        json['last_message_text'],
        json['message_preview'],
        json['recent_message_text'],
        json['message'],
        json['content'],
        lastMessageMap,
        recentMessageMap,
        lastMessageMap['content'],
        lastMessageMap['message'],
        lastMessageMap['text'],
        lastMessageMap['body'],
        recentMessageMap['content'],
        recentMessageMap['message'],
        recentMessageMap['text'],
        recentMessageMap['body'],
      ], fallback: ''),
      updatedAt: DateTime.tryParse(
        fallbackString([
          json['updated_at'],
          json['created_at'],
          json['last_message_sent'],
        ]),
      ),
      unreadCount: int.tryParse((json['unread_count'] ?? '0').toString()) ?? 0,
      participantRole: fallbackString([
        json['participant_role'],
        json['other_participant_role'],
        participantMap['role'],
        babysitterMap['role'],
        parentMap['role'],
        userMap['role'],
      ]),
      participantOccupation: fallbackString([
        json['participant_occupation'],
        json['other_participant_occupation'],
        json['babysitter_occupation'],
        json['parent_occupation'],
        participantMap['occupation'],
        babysitterMap['occupation'],
        parentMap['occupation'],
        userMap['occupation'],
      ]),
      participantId: fallbackString([
        json['participant_id'],
        json['other_participant_id'],
        json['babysitter_id'],
        json['parent_id'],
        participantMap['id'],
        participantMap['user_id'],
        babysitterMap['id'],
        babysitterMap['user_id'],
        parentMap['id'],
        parentMap['user_id'],
        userMap['id'],
        userMap['user_id'],
      ]),
      participantPhone: fallbackString([
        json['participant_phone'],
        json['participant_phone_number'],
        json['other_participant_phone'],
        json['other_participant_phone_number'],
        json['babysitter_phone'],
        json['babysitter_phone_number'],
        json['parent_phone'],
        json['parent_phone_number'],
        participantMap['phone'],
        participantMap['phone_number'],
        babysitterMap['phone'],
        babysitterMap['phone_number'],
        parentMap['phone'],
        parentMap['phone_number'],
        userMap['phone'],
        userMap['phone_number'],
      ]),
      profileImageUrl: fallbackString([
        json['profile_image'],
        json['profile_picture'],
        json['profile_picture_url'],
        json['avatar'],
        json['avatar_url'],
        json['participant_avatar'],
        json['participant_avatar_url'],
        json['participant_profile_picture'],
        json['participant_profile_picture_url'],
        json['other_participant_profile_picture'],
        json['other_participant_profile_picture_url'],
        json['babysitter_profile_picture'],
        json['babysitter_profile_picture_url'],
        json['parent_profile_picture'],
        json['parent_profile_picture_url'],
        participantMap['profile_picture'],
        participantMap['profile_picture_url'],
        participantMap['avatar'],
        participantMap['avatar_url'],
        babysitterMap['profile_picture'],
        babysitterMap['profile_picture_url'],
        babysitterMap['avatar'],
        babysitterMap['avatar_url'],
        parentMap['profile_picture'],
        parentMap['profile_picture_url'],
        parentMap['avatar'],
        parentMap['avatar_url'],
        userMap['profile_picture'],
        userMap['profile_picture_url'],
        userMap['avatar'],
        userMap['avatar_url'],
      ]),
      lastSenderId: fallbackString([
        json['last_sender_id'],
        lastMessageMap['sender_id'],
        recentMessageMap['sender_id'],
      ]),
      isRead: json['is_read'] is bool ? json['is_read'] as bool : null,
      isLocked: json['is_locked'] is bool ? json['is_locked'] as bool : null,
    );
  }
}
