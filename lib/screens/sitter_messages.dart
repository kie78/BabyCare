import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'sitter_account.dart';
import 'sitter_dashboard.dart';

class SitterMessagesScreen extends StatefulWidget {
  const SitterMessagesScreen({super.key});

  @override
  State<SitterMessagesScreen> createState() => _SitterMessagesScreenState();
}

class _SitterMessagesScreenState extends State<SitterMessagesScreen> {
  final List<Conversation> conversations = [
    Conversation(
      id: '1',
      name: 'Sarah M.',
      profileImage: 'assets/logo.png',
      lastMessage: 'Can you start on Monday?',
      timestamp: '2 hours ago',
      isUnread: true,
      occupation: 'Nurse',
    ),
    Conversation(
      id: '2',
      name: 'James K.',
      profileImage: 'assets/logo.png',
      lastMessage: 'Thank you for the update!',
      timestamp: '4 hours ago',
      isUnread: true,
      occupation: 'Engineer',
    ),
    Conversation(
      id: '3',
      name: 'Emma L.',
      profileImage: 'assets/logo.png',
      lastMessage: 'Looking forward to meeting you',
      timestamp: '1 day ago',
      isUnread: false,
      occupation: 'Teacher',
    ),
    Conversation(
      id: '4',
      name: 'John D.',
      profileImage: 'assets/logo.png',
      lastMessage: 'What are your rates?',
      timestamp: '2 days ago',
      isUnread: false,
      occupation: 'Doctor',
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
            SitterChatThreadScreen(conversation: conversations[index]),
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
                  conversation.occupation,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
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
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SitterDashboardScreen(),
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
                      builder: (context) => const SitterAccountScreen(),
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
class SitterChatThreadScreen extends StatefulWidget {
  final Conversation conversation;

  const SitterChatThreadScreen({super.key, required this.conversation});

  @override
  State<SitterChatThreadScreen> createState() => _SitterChatThreadScreenState();
}

class _SitterChatThreadScreenState extends State<SitterChatThreadScreen> {
  late TextEditingController _messageController;
  final List<_ChatMessage> messages = [
    _ChatMessage(
      id: '1',
      text: 'Hi! Are you available this week?',
      isOutgoing: false,
      timestamp: '2:30 PM',
    ),
    _ChatMessage(
      id: '2',
      text: 'Yes, I am available Monday to Wednesday',
      isOutgoing: true,
      timestamp: '2:45 PM',
    ),
    _ChatMessage(
      id: '3',
      text: 'Perfect! Can you start on Monday morning?',
      isOutgoing: false,
      timestamp: '2:50 PM',
    ),
    _ChatMessage(
      id: '4',
      text: 'Can you start on Monday?',
      isOutgoing: false,
      timestamp: '2 hours ago',
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
                  widget.conversation.occupation,
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
  final String occupation;

  Conversation({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.lastMessage,
    required this.timestamp,
    required this.isUnread,
    required this.occupation,
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
