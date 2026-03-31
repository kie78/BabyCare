import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/theme.dart';
import '../models/babysitter_profile.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../providers/auth_provider.dart';
import '../providers/conversations_provider.dart';
import '../providers/parent_provider.dart';
import 'gateway_screen.dart';
import 'parent_account.dart';
import 'parent_discover.dart';

class ParentMessagesScreen extends StatefulWidget {
  const ParentMessagesScreen({super.key});

  @override
  State<ParentMessagesScreen> createState() => _ParentMessagesScreenState();
}

class _ParentMessagesScreenState extends State<ParentMessagesScreen> {
  final Map<String, BabysitterProfile> _contactProfiles =
      <String, BabysitterProfile>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  Future<void> _loadConversations() async {
    final conversationsProvider = context.read<ConversationsProvider>();
    await conversationsProvider.loadConversations();
    if (!mounted) {
      return;
    }
    await _hydrateContactProfiles(conversationsProvider.conversations);
    if (!mounted) {
      return;
    }
    await _handleUnauthorized(conversationsProvider.lastStatusCode);
  }

  bool _isPlaceholderValue(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'unknown' ||
        normalized == 'babysitter' ||
        normalized == 'parent';
  }

  Future<void> _hydrateContactProfiles(List<Conversation> conversations) async {
    final parentProvider = context.read<ParentProvider>();
    final updatedProfiles = Map<String, BabysitterProfile>.from(_contactProfiles);

    for (final conversation in conversations) {
      final participantId = (conversation.participantId ?? '').trim();
      final needsMetadata = _isPlaceholderValue(conversation.participantName) ||
          (conversation.profileImageUrl ?? '').trim().isEmpty ||
          (conversation.participantPhone ?? '').trim().isEmpty;

      if (!needsMetadata || participantId.isEmpty) {
        continue;
      }

      final profile = await parentProvider.fetchBabysitterById(participantId);
      if (profile != null) {
        updatedProfiles[conversation.id] = profile;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _contactProfiles
        ..clear()
        ..addAll(updatedProfiles);
    });
  }

  String _resolveParticipantName(Conversation conversation) {
    final name = conversation.participantName.trim();
    if (!_isPlaceholderValue(name)) {
      return name;
    }

    final fallback = (_contactProfiles[conversation.id]?.fullName ?? '').trim();
    return fallback.isEmpty ? 'Babysitter' : fallback;
  }

  String _resolveParticipantSubtitle(Conversation conversation) {
    final occupation = (conversation.participantOccupation ?? '').trim();
    if (occupation.isNotEmpty) {
      return occupation;
    }

    final role = (conversation.participantRole ?? '').trim();
    if (!_isPlaceholderValue(role)) {
      return role;
    }

    return 'Babysitter';
  }

  String? _resolveParticipantAvatar(Conversation conversation) {
    final avatar = (conversation.profileImageUrl ?? '').trim();
    if (avatar.isNotEmpty) {
      return avatar;
    }

    return _contactProfiles[conversation.id]?.profilePictureUrl;
  }

  String? _resolveParticipantPhone(Conversation conversation) {
    final phone = (conversation.participantPhone ?? '').trim();
    if (phone.isNotEmpty) {
      return phone;
    }

    return _contactProfiles[conversation.id]?.phone;
  }

  String _displayLastMessage(Conversation conversation) {
    final lastMessage = (conversation.lastMessage ?? '').trim();
    return lastMessage.isEmpty ? 'No messages yet' : lastMessage;
  }

  Future<void> _handleUnauthorized(int? statusCode) async {
    if (statusCode != 401 && statusCode != 403) {
      return;
    }

    await context.read<AuthProvider>().handleUnauthorized();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GatewayScreen()),
      (route) => false,
    );
  }

  void _onConversationPressed(Conversation conversation) {
    final participantProfile = _contactProfiles[conversation.id];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParentChatThreadScreen(
          conversationId: conversation.id,
          title: _resolveParticipantName(conversation),
          subtitle: _resolveParticipantSubtitle(conversation),
          avatarUrl: _resolveParticipantAvatar(conversation),
          phoneNumber: _resolveParticipantPhone(conversation),
          participantProfile: participantProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationsProvider>(
      builder: (context, conversationsProvider, _) {
        final conversations = conversationsProvider.conversations;
        final currentUserId = context.watch<AuthProvider>().currentUser?.id;
        final unreadCount = conversations
            .where((conversation) => conversation.hasUnreadFor(currentUserId))
            .length;

        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          extendBody: true,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(unreadCount),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: _buildConversationBody(
                          conversationsProvider,
                          conversations,
                        ),
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
      },
    );
  }

  Widget _buildHeader(int unreadCount) {
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
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BabyCareTheme.primaryBerry,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
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

  Widget _buildConversationBody(
    ConversationsProvider conversationsProvider,
    List<Conversation> conversations,
  ) {
    if (conversationsProvider.isLoadingConversations && conversations.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (conversationsProvider.errorMessage != null && conversations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    conversationsProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: BabyCareTheme.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadConversations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BabyCareTheme.primaryBerry,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (conversations.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [_buildEmptyState()],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      itemCount: conversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return GestureDetector(
          onTap: () => _onConversationPressed(conversation),
          child: _buildConversationCard(conversation),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 160),
      child: Center(
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
      ),
    );
  }

  Widget _buildConversationCard(Conversation conversation) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isUnread = conversation.hasUnreadFor(currentUserId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread
            ? BabyCareTheme.lightPink
            : BabyCareTheme.lightGrey.withValues(alpha: 0.8),
        border: Border.all(
          color: isUnread
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
                    color: isUnread
                        ? BabyCareTheme.primaryBerry
                        : BabyCareTheme.lightGrey,
                    width: isUnread ? 2 : 1,
                  ),
                ),
                child: ClipOval(
                  child: _buildProfileImage(
                    _resolveParticipantAvatar(conversation),
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
                        _resolveParticipantName(conversation),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: BabyCareTheme.darkGrey,
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(conversation.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _resolveParticipantSubtitle(conversation),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _displayLastMessage(conversation),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
                    fontWeight: isUnread ? FontWeight.w600 : null,
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

  Widget _buildProfileImage(String? imageUrl) {
    final normalizedUrl = (imageUrl ?? '').trim();

    if (normalizedUrl.isEmpty) {
      return Image.asset('assets/logo.png', fit: BoxFit.cover);
    }

    return Image.network(
      normalizedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/logo.png', fit: BoxFit.cover);
      },
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Now';
    }

    final now = DateTime.now();
    final difference = now.difference(value);
    if (difference.inMinutes < 1) {
      return 'Now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }

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

class ParentChatThreadScreen extends StatefulWidget {
  const ParentChatThreadScreen({
    super.key,
    required this.conversationId,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.phoneNumber,
    this.participantProfile,
  });

  final String conversationId;
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final String? phoneNumber;
  final BabysitterProfile? participantProfile;

  @override
  State<ParentChatThreadScreen> createState() => _ParentChatThreadScreenState();
}

class _ParentChatThreadScreenState extends State<ParentChatThreadScreen> {
  late final TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  BabysitterProfile? _participantProfile;
  bool _isLoadingParticipantProfile = false;

  static const Set<String> _identityPlaceholders = <String>{
    'unknown',
    'babysitter',
    'parent',
  };

  String _firstNonEmpty(List<String?> values, {required String fallback}) {
    for (final value in values) {
      final text = (value ?? '').trim();
      if (text.isNotEmpty && !_identityPlaceholders.contains(text.toLowerCase())) {
        return text;
      }
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _participantProfile = widget.participantProfile;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    context.read<ConversationsProvider>().stopPolling(
      conversationId: widget.conversationId,
    );
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final conversationsProvider = context.read<ConversationsProvider>();
    await conversationsProvider.openConversation(widget.conversationId);
    conversationsProvider.startPolling(widget.conversationId);
    if (!mounted) {
      return;
    }
    await _hydrateParticipantProfile();
    if (!mounted) {
      return;
    }
    await _handleUnauthorized(conversationsProvider.lastStatusCode);
    if (!mounted) {
      return;
    }
    _jumpToLatest();
  }

  Future<void> _hydrateParticipantProfile() async {
    final conversation = context.read<ConversationsProvider>().conversationById(
      widget.conversationId,
    );
    final participantId = (conversation?.participantId ?? '').trim();

    if (participantId.isEmpty || _isLoadingParticipantProfile) {
      return;
    }

    final parentProvider = context.read<ParentProvider>();
    final cachedProfile = parentProvider.cachedBabysitter(participantId);
    if (cachedProfile != null) {
      setState(() {
        _participantProfile ??= cachedProfile;
      });
      return;
    }

    setState(() {
      _isLoadingParticipantProfile = true;
    });

    final fetchedProfile = await parentProvider.fetchBabysitterById(participantId);
    if (!mounted) {
      return;
    }

    setState(() {
      _participantProfile ??= fetchedProfile;
      _isLoadingParticipantProfile = false;
    });
  }

  Future<void> _handleUnauthorized(int? statusCode) async {
    if (statusCode != 401 && statusCode != 403) {
      return;
    }

    await context.read<AuthProvider>().handleUnauthorized();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GatewayScreen()),
      (route) => false,
    );
  }

  Future<void> _onSendPressed() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) {
      return;
    }

    final conversationsProvider = context.read<ConversationsProvider>();
    final success = await conversationsProvider.sendMessage(
      conversationId: widget.conversationId,
      content: content,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      await _handleUnauthorized(conversationsProvider.lastStatusCode);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            conversationsProvider.errorMessage ??
                'Unable to send your message right now.',
          ),
        ),
      );
      return;
    }

    _messageController.clear();
    unawaited(_loadMessages());
  }

  Future<void> _onCallPressed() async {
    final conversation = context.read<ConversationsProvider>().conversationById(
      widget.conversationId,
    );
    final phoneNumber = _firstNonEmpty(
      [
        _participantProfile?.phone,
        conversation?.participantPhone,
        widget.phoneNumber,
      ],
      fallback: '',
    );
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This sitter has not shared a phone number.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) {
      return;
    }

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the phone app on this device.')),
      );
    }
  }

  void _jumpToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().currentUser?.id;

    return Consumer<ConversationsProvider>(
      builder: (context, conversationsProvider, _) {
        final messages = conversationsProvider.activeMessages;
        final conversation = conversationsProvider.conversationById(
          widget.conversationId,
        );
        final title = _firstNonEmpty(
          [
            _participantProfile?.fullName,
            conversation?.participantName,
            widget.title,
          ],
          fallback: 'Babysitter',
        );
        final subtitle = _firstNonEmpty(
          [
            conversation?.participantOccupation,
            conversation?.participantRole,
            widget.subtitle,
          ],
          fallback: 'Babysitter',
        );
        final avatarUrl = _firstNonEmpty(
          [
            _participantProfile?.profilePictureUrl,
            conversation?.profileImageUrl,
            widget.avatarUrl,
          ],
          fallback: '',
        );

        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(
                  title: title,
                  subtitle: subtitle,
                  avatarUrl: avatarUrl,
                ),
                Expanded(
                  child: _buildMessagesBody(
                    conversationsProvider,
                    messages,
                    currentUserId,
                  ),
                ),
                _buildInputArea(conversationsProvider.isSendingMessage),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader({
    required String title,
    required String subtitle,
    required String avatarUrl,
  }) {
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BabyCareTheme.primaryGradient,
            ),
            child: ClipOval(
              child: _buildProfileImage(avatarUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _onCallPressed,
            child: Icon(
              Icons.call_outlined,
              color: BabyCareTheme.primaryBerry,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    final normalizedUrl = (imageUrl ?? '').trim();

    if (normalizedUrl.isEmpty) {
      return Image.asset('assets/logo.png', fit: BoxFit.cover);
    }

    return Image.network(
      normalizedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/logo.png', fit: BoxFit.cover);
      },
    );
  }

  Widget _buildMessagesBody(
    ConversationsProvider conversationsProvider,
    List<Message> messages,
    String? currentUserId,
  ) {
    if (conversationsProvider.isLoadingMessages && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (conversationsProvider.errorMessage != null && messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                conversationsProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadMessages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BabyCareTheme.primaryBerry,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start the conversation here.',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(
          message: message,
          isOutgoing:
              currentUserId != null && message.senderId == currentUserId,
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required Message message,
    required bool isOutgoing,
  }) {
    final timestamp = Text(
      _formatMessageTime(message.createdAt),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        color: isOutgoing
            ? BabyCareTheme.darkGrey.withValues(alpha: 0.55)
            : BabyCareTheme.darkGrey.withValues(alpha: 0.5),
        fontSize: 11,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isOutgoing
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isOutgoing)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                    child: Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: timestamp,
                  ),
                ],
              ),
            ),
          if (isOutgoing)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
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
                    child: Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.universalWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: timestamp,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Now';
    }

    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildInputArea(bool isSendingMessage) {
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
              onTap: isSendingMessage ? null : _onSendPressed,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: BabyCareTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: isSendingMessage
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BabyCareTheme.universalWhite,
                          ),
                        ),
                      )
                    : const Icon(
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
