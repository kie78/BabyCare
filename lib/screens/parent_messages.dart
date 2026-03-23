import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'parent_discover.dart';
import 'parent_account.dart';

class ParentMessagesScreen extends StatefulWidget {
  const ParentMessagesScreen({super.key});

  @override
  State<ParentMessagesScreen> createState() => _ParentMessagesScreenState();
}

class _ParentMessagesScreenState extends State<ParentMessagesScreen> {
  final List<Conversation> conversations = [
    Conversation(
      id: '1',
      name: 'Maria Elena',
      profileImage: 'assets/logo.png',
      lastMessage: 'I can start next Monday. What time works best?',
      timestamp: '1 hour ago',
      isUnread: true,
      role: 'Sitter',
    ),
    Conversation(
      id: '2',
      name: 'Grace Okello',
      profileImage: 'assets/logo.png',
      lastMessage: 'Thanks for the opportunity!',
      timestamp: '3 hours ago',
      isUnread: true,
      role: 'Sitter',
    ),
    Conversation(
      id: '3',
      name: 'Amina Hassan',
      profileImage: 'assets/logo.png',
      lastMessage: 'I would be happy to help your family',
      timestamp: '1 day ago',
      isUnread: false,
      role: 'Sitter',
    ),
    Conversation(
      id: '4',
      name: 'Sarah Namukasa',
      profileImage: 'assets/logo.png',
      lastMessage: 'What are your preferred working hours?',
      timestamp: '2 days ago',
      isUnread: false,
      role: 'Sitter',
    ),
  ];

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    _unreadCount = conversations.where((c) => c.isUnread).length;
  }

  void _onConversationPressed(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ParentChatThreadScreen(conversation: conversations[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      extendBody: true,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Fixed Header
                _buildHeader(),

                // Scrollable Conversations
                Expanded(
                  child: conversations.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                          itemCount: conversations.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return GestureDetector(
                              onTap: () => _onConversationPressed(index),
                              child: _buildConversationCard(conversation),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 21,
            right: 21,
            bottom: 16,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  /// Header with title and unread count
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BabyCareTheme.primaryBerry,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unreadCount',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: BabyCareTheme.universalWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: BabyCareTheme.primaryBerry.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Conversation card
  Widget _buildConversationCard(Conversation conversation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: conversation.isUnread
            ? BabyCareTheme.lightPink
            : BabyCareTheme.lightGrey.withValues(alpha: 0.8),
        border: Border.all(
          color: conversation.isUnread
              ? BabyCareTheme.primaryBerry.withValues(alpha: 0.2)
              : BabyCareTheme.lightGrey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Row(
        children: [
          // Avatar with unread indicator
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BabyCareTheme.primaryGradient,
                  border: Border.all(
                    color: conversation.isUnread
                        ? BabyCareTheme.primaryBerry
                        : BabyCareTheme.lightGrey,
                    width: conversation.isUnread ? 2 : 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    conversation.profileImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conversation.name,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: BabyCareTheme.darkGrey,
                          fontWeight: conversation.isUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      conversation.timestamp,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  conversation.lastMessage,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
                    fontWeight: conversation.isUnread ? FontWeight.w600 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom navigation bar
  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: BabyCareTheme.universalWhite,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: BabyCareTheme.darkGrey.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildNavItem(
                icon: Icons.explore_outlined,
                label: 'Discover',
                isActive: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ParentDiscoverScreen(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.message_outlined,
                label: 'Messages',
                isActive: true,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.person_outline,
                label: 'Account',
                isActive: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ParentAccountScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive
                ? BabyCareTheme.primaryBerry
                : BabyCareTheme.darkGrey.withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: isActive
                  ? BabyCareTheme.primaryBerry
                  : BabyCareTheme.darkGrey.withValues(alpha: 0.5),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Chat Thread Screen
class ParentChatThreadScreen extends StatefulWidget {
  final Conversation conversation;

  const ParentChatThreadScreen({super.key, required this.conversation});

  @override
  State<ParentChatThreadScreen> createState() => _ParentChatThreadScreenState();
}

class _ParentChatThreadScreenState extends State<ParentChatThreadScreen> {
  late TextEditingController _messageController;
  final List<_ChatMessage> messages = [
    _ChatMessage(
      id: '1',
      text: 'Hi! Are you available starting next week?',
      isOutgoing: false,
      timestamp: '2:30 PM',
    ),
    _ChatMessage(
      id: '2',
      text: 'Yes, I am available. What days do you need me?',
      isOutgoing: true,
      timestamp: '2:45 PM',
    ),
    _ChatMessage(
      id: '3',
      text: 'I need someone Monday through Friday, 9AM to 5PM',
      isOutgoing: false,
      timestamp: '2:50 PM',
    ),
    _ChatMessage(
      id: '4',
      text: 'I can start next Monday. What time works best?',
      isOutgoing: false,
      timestamp: '1 hour ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    if (_messageController.text.isEmpty) return;

    setState(() {
      messages.add(
        _ChatMessage(
          id: '${messages.length + 1}',
          text: _messageController.text,
          isOutgoing: true,
          timestamp: 'Now',
        ),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: messages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Message Input
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  /// Header with conversation info
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BabyCareTheme.universalWhite,
        border: Border(
          bottom: BorderSide(color: BabyCareTheme.lightGrey, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back,
              color: BabyCareTheme.primaryBerry,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation.name,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.conversation.role,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.call_outlined,
            color: BabyCareTheme.primaryBerry,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Message bubble
  Widget _buildMessageBubble(_ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: message.isOutgoing
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isOutgoing)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: BabyCareTheme.lightGrey,
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusLarge,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.timestamp,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (message.isOutgoing)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: BabyCareTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusLarge,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.universalWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.timestamp,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.universalWhite.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Input area
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BabyCareTheme.universalWhite,
        border: Border(
          top: BorderSide(color: BabyCareTheme.lightGrey, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: BabyCareTheme.lightGrey,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      BabyCareTheme.radiusLarge,
                    ),
                    borderSide: const BorderSide(
                      color: BabyCareTheme.lightGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      BabyCareTheme.radiusLarge,
                    ),
                    borderSide: const BorderSide(
                      color: BabyCareTheme.primaryBerry,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _onSendPressed,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: BabyCareTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: BabyCareTheme.universalWhite,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conversation data model
class Conversation {
  final String id;
  final String name;
  final String profileImage;
  final String lastMessage;
  final String timestamp;
  final bool isUnread;
  final String role;

  Conversation({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.lastMessage,
    required this.timestamp,
    required this.isUnread,
    required this.role,
  });
}

/// Chat message data model
class _ChatMessage {
  final String id;
  final String text;
  final bool isOutgoing;
  final String timestamp;

  _ChatMessage({
    required this.id,
    required this.text,
    required this.isOutgoing,
    required this.timestamp,
  });
}
