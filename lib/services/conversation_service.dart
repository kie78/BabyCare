import '../models/conversation.dart';
import '../models/message.dart';
import 'api_client.dart';

class ConversationService {
  ConversationService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Conversation> _parseConversations(dynamic response) {
    final rawList = response is List
        ? response
        : response is Map<String, dynamic>
        ? (response['data'] ?? response['items'] ?? response['conversations'])
        : null;

    if (rawList is! List) {
      return const <Conversation>[];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList();
  }

  List<Conversation> _mergeConversationPreviews(
    List<Conversation> conversations,
    List<Conversation> previews,
  ) {
    if (previews.isEmpty) {
      return conversations;
    }

    final previewsById = <String, Conversation>{
      for (final preview in previews) preview.id: preview,
    };

    final merged = conversations.map((conversation) {
      final preview = previewsById[conversation.id];
      if (preview == null) {
        return conversation;
      }

      return conversation.copyWith(
        participantName: preview.participantName,
        lastMessage: (preview.lastMessage ?? '').trim().isEmpty
            ? conversation.lastMessage
            : preview.lastMessage,
        updatedAt: preview.updatedAt ?? conversation.updatedAt,
        lastSenderId: preview.lastSenderId,
        isRead: preview.isRead,
        isLocked: preview.isLocked,
      );
    }).toList();

    merged.sort((first, second) {
      final firstTime = first.updatedAt;
      final secondTime = second.updatedAt;
      if (firstTime == null && secondTime == null) {
        return 0;
      }
      if (firstTime == null) {
        return 1;
      }
      if (secondTime == null) {
        return -1;
      }
      return secondTime.compareTo(firstTime);
    });

    return merged;
  }

  List<Message> _parseMessages(dynamic response) {
    final rawList = response is List
        ? response
        : response is Map<String, dynamic>
        ? (response['data'] ?? response['items'] ?? response['messages'])
        : null;

    if (rawList is! List) {
      return const <Message>[];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Message.fromJson)
        .toList();
  }

  Future<List<Conversation>> getConversations() async {
    final response = await _apiClient.get('/api/v1/conversations');
    final conversations = _parseConversations(response);

    try {
      final previewsResponse = await _apiClient.get('/api/v1/conversations/previews');
      final previews = _parseConversations(previewsResponse);
      return _mergeConversationPreviews(conversations, previews);
    } catch (_) {
      return conversations;
    }
  }

  Future<Conversation> startConversation(String babysitterId) async {
    final response = await _apiClient.post(
      '/api/v1/conversations',
      body: {'babysitter_id': babysitterId},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Invalid conversation response',
      );
    }

    return Conversation.fromJson(response);
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final response = await _apiClient.get(
      '/api/v1/conversations/$conversationId/messages',
    );
    return _parseMessages(response);
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/conversations/$conversationId/messages',
      body: {'content': content.trim(), 'message': content.trim()},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(statusCode: 500, message: 'Invalid message response');
    }

    return Message.fromJson(response);
  }
}
