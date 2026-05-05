import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/parent_public_profile.dart';
import '../models/profile_view.dart';
import '../providers/auth_provider.dart';
import '../providers/babysitter_dashboard_provider.dart';
import '../providers/conversations_provider.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_toast.dart';
import 'gateway_screen.dart';
import 'parent_profile_sitter_view.dart';
import 'sitter_account.dart';
import 'sitter_dashboard.dart';

class SitterMessagesScreen extends StatefulWidget {
  const SitterMessagesScreen({super.key});

  @override
  State<SitterMessagesScreen> createState() => _SitterMessagesScreenState();
}

class _SitterMessagesScreenState extends State<SitterMessagesScreen> {
  final Map<String, ProfileView> _visitorProfilesByConversation =
      <String, ProfileView>{};

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
    await _hydrateVisitorProfiles(conversationsProvider.conversations);
    if (!mounted) {
      return;
    }
    await _handleUnauthorized(conversationsProvider.lastStatusCode);
  }

  Future<void> _hydrateVisitorProfiles(List<Conversation> conversations) async {
    final dashboardProvider = context.read<BabysitterDashboardProvider>();
    if (dashboardProvider.profileViews.isEmpty) {
      await dashboardProvider.loadDashboard();
      if (!mounted) {
        return;
      }
    }

    final visitors = dashboardProvider.profileViews;
    if (visitors.isEmpty) {
      return;
    }

    final mappedProfiles = <String, ProfileView>{};
    for (final conversation in conversations) {
      final participantId = (conversation.participantId ?? '').trim();
      final participantName = conversation.participantName.trim().toLowerCase();
      final matchedVisitor = visitors
          .where((visitor) {
            final visitorId = visitor.id.trim();
            final visitorName = visitor.viewerName.trim().toLowerCase();
            return (participantId.isNotEmpty && visitorId == participantId) ||
                (participantName.isNotEmpty && visitorName == participantName);
          })
          .cast<ProfileView?>()
          .firstWhere((visitor) => visitor != null, orElse: () => null);

      if (matchedVisitor != null) {
        mappedProfiles[conversation.id] = matchedVisitor;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _visitorProfilesByConversation
        ..clear()
        ..addAll(mappedProfiles);
    });
  }

  String? _resolveParticipantAvatar(Conversation conversation) {
    final avatarUrl = (conversation.profileImageUrl ?? '').trim();
    if (avatarUrl.isNotEmpty) {
      return avatarUrl;
    }

    return _visitorProfilesByConversation[conversation.id]?.profileImageUrl;
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SitterChatThreadScreen(
          conversationId: conversation.id,
          title: conversation.participantName,
          subtitle:
              (conversation.participantOccupation ??
                      conversation.participantRole ??
                      'Parent')
                  .trim(),
          participantId: (conversation.participantId ?? '').trim(),
          avatarUrl: _resolveParticipantAvatar(conversation),
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
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [_buildConversationSkeletonList()],
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

  Widget _buildConversationSkeletonList() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppSkeletonCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: const [
                AppSkeletonCircle(size: 56),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: AppSkeletonBlock(height: 14)),
                          SizedBox(width: 12),
                          AppSkeletonBlock(width: 44, height: 10),
                        ],
                      ),
                      SizedBox(height: 8),
                      AppSkeletonBlock(width: 90, height: 12),
                      SizedBox(height: 10),
                      AppSkeletonBlock(width: 170, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                        conversation.participantName,
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
                  (conversation.participantOccupation ?? 'Parent').trim(),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
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

class SitterChatThreadScreen extends StatefulWidget {
  const SitterChatThreadScreen({
    super.key,
    required this.conversationId,
    required this.title,
    required this.subtitle,
    this.participantId,
    this.avatarUrl,
  });

  final String conversationId;
  final String title;
  final String subtitle;
  final String? participantId;
  final String? avatarUrl;

  @override
  State<SitterChatThreadScreen> createState() => _SitterChatThreadScreenState();
}

class _SitterChatThreadScreenState extends State<SitterChatThreadScreen> {
  late final TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  ParentPublicProfile? _participantProfile;
  bool _isLoadingParticipantProfile = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
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
    final dashboardProvider = context.read<BabysitterDashboardProvider>();
    final conversation = context.read<ConversationsProvider>().conversationById(
      widget.conversationId,
    );
    final participantId =
        (widget.participantId ?? conversation?.participantId ?? '').trim();

    if (participantId.isEmpty || _isLoadingParticipantProfile) {
      return;
    }

    final cachedProfile = dashboardProvider.cachedParentProfile(participantId);
    if (cachedProfile != null) {
      setState(() {
        _participantProfile ??= cachedProfile;
      });
      return;
    }

    setState(() {
      _isLoadingParticipantProfile = true;
    });

    final fetchedProfile = await dashboardProvider.fetchParentPublicProfile(
      participantId,
    );
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
      AppToast.showError(
        context,
        conversationsProvider.errorMessage ??
            'Unable to send your message right now.',
        statusCode: conversationsProvider.lastStatusCode,
        fallbackMessage: 'Unable to send your message right now.',
      );
      return;
    }

    _messageController.clear();
    AppToast.showSuccess(context, 'Message sent successfully.');
    unawaited(_loadMessages());
  }

  Future<void> _openParticipantProfile() async {
    final conversation = context.read<ConversationsProvider>().conversationById(
      widget.conversationId,
    );
    final participantId =
        (widget.participantId ??
                conversation?.participantId ??
                _participantProfile?.id ??
                '')
            .trim();
    final participantName =
        (_participantProfile?.fullName ??
                conversation?.participantName ??
                widget.title)
            .trim();
    final participantRole =
        (_participantProfile?.occupation ??
                conversation?.participantOccupation ??
                widget.subtitle)
            .trim();
    final participantLocation =
        (_participantProfile?.primaryLocation ?? _participantProfile?.location)
            ?.trim() ??
        '';
    final participantHours = (_participantProfile?.preferredHours ?? '').trim();
    final participantPhone = (conversation?.participantPhone ?? '').trim();
    final avatarUrl = (_participantProfile?.profilePictureUrl ?? '').trim();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParentProfileSitterViewScreen(
          parentId: participantId,
          parentName: participantName.isEmpty ? 'Parent' : participantName,
          profileImage: avatarUrl,
          location: participantLocation,
          job: participantRole.isEmpty ? 'Parent' : participantRole,
          hours: participantHours,
          phoneNumber: participantPhone,
        ),
      ),
    );
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
        final headerAvatarUrl =
            (_participantProfile?.profilePictureUrl ?? '').trim().isNotEmpty
            ? _participantProfile?.profilePictureUrl
            : (conversation?.profileImageUrl ?? '').trim().isNotEmpty
            ? conversation?.profileImageUrl
            : widget.avatarUrl;
        _jumpToLatest();

        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(headerAvatarUrl),
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

  Widget _buildHeader(String? avatarUrl) {
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
            child: GestureDetector(
              onTap: _openParticipantProfile,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BabyCareTheme.primaryGradient,
                    ),
                    child: ClipOval(child: _buildProfileImage(avatarUrl)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(
                                color: BabyCareTheme.darkGrey,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: BabyCareTheme.darkGrey.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                        ),
                      ],
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
      return _buildMessageThreadSkeleton();
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

  Widget _buildMessageThreadSkeleton() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppSkeletonCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBlock(width: 170, height: 12),
                SizedBox(height: 8),
                AppSkeletonBlock(width: 50, height: 10),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: AppSkeletonCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppSkeletonBlock(width: 160, height: 12),
                SizedBox(height: 8),
                AppSkeletonBlock(width: 48, height: 10),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: AppSkeletonCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBlock(width: 190, height: 12),
                SizedBox(height: 8),
                AppSkeletonBlock(width: 54, height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required Message message,
    required bool isOutgoing,
  }) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isOutgoing ? null : BabyCareTheme.lightGrey,
        gradient: isOutgoing ? BabyCareTheme.primaryGradient : null,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Text(
        message.content,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: isOutgoing
              ? BabyCareTheme.universalWhite
              : BabyCareTheme.darkGrey,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isOutgoing
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: isOutgoing
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                bubble,
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _formatMessageTime(message.createdAt),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
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

    final localTime = createdAt.isUtc ? createdAt.toLocal() : createdAt;
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
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
