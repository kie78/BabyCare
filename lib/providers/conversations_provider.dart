import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api_client.dart';
import '../services/conversation_service.dart';

class ConversationsProvider extends ChangeNotifier {
  ConversationsProvider({required ConversationService conversationService})
    : _conversationService = conversationService;

  final ConversationService _conversationService;

  List<Conversation> _conversations = const <Conversation>[];
  final Map<String, List<Message>> _messagesByConversation =
      <String, List<Message>>{};
  Timer? _pollingTimer;
  String? _activeConversationId;
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  String? _errorMessage;
  String? _successMessage;
  int? _lastStatusCode;

  List<Conversation> get conversations => _conversations;
  List<Message> get activeMessages =>
      _messagesByConversation[_activeConversationId] ?? const <Message>[];
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int? get lastStatusCode => _lastStatusCode;
  String? get activeConversationId => _activeConversationId;

  Conversation? conversationById(String conversationId) {
    for (final conversation in _conversations) {
      if (conversation.id == conversationId) {
        return conversation;
      }
    }
    return null;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      _conversations = await _conversationService.getConversations();
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load your conversations right now.';
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<Conversation?> startConversation(String babysitterId) async {
    _errorMessage = null;
    _successMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      final createdConversation = await _conversationService.startConversation(
        babysitterId,
      );
      await loadConversations();
      final conversation = conversationById(createdConversation.id) ??
          createdConversation;

      final existingIndex = _conversations.indexWhere(
        (item) => item.id == conversation.id,
      );
      if (existingIndex >= 0) {
        _conversations[existingIndex] = conversation;
      } else {
        _conversations = [conversation, ..._conversations];
      }
      return conversation;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'Unable to start a conversation right now.';
      notifyListeners();
      return null;
    }
  }

  Future<void> openConversation(String conversationId) async {
    _activeConversationId = conversationId;
    _isLoadingMessages = true;
    _errorMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      final messages = await _conversationService.getMessages(conversationId);
      _messagesByConversation[conversationId] = messages;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load messages for this conversation.';
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  void startPolling(
    String conversationId, {
    Duration interval = const Duration(seconds: 8),
  }) {
    _activeConversationId = conversationId;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) {
      if (_activeConversationId == null) {
        return;
      }
      openConversation(_activeConversationId!);
    });
  }

  void stopPolling({String? conversationId}) {
    if (conversationId != null && _activeConversationId != conversationId) {
      return;
    }
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _activeConversationId = null;
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    _isSendingMessage = true;
    _errorMessage = null;
    _successMessage = null;
    _lastStatusCode = null;
    notifyListeners();

    try {
      final message = await _conversationService.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      final existing = _messagesByConversation[conversationId] ?? <Message>[];
      _messagesByConversation[conversationId] = [...existing, message];
      await loadConversations();
      return true;
    } on ApiException catch (error) {
      _lastStatusCode = error.statusCode;
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to send your message right now.';
      return false;
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
