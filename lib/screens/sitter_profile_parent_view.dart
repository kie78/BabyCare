import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/babysitter_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/conversations_provider.dart';
import '../providers/parent_provider.dart';
import 'gateway_screen.dart';
import 'parent_messages.dart';

class SitterProfileParentViewScreen extends StatefulWidget {
  const SitterProfileParentViewScreen({super.key, required this.babysitterId});

  final String babysitterId;

  @override
  State<SitterProfileParentViewScreen> createState() =>
      _SitterProfileParentViewScreenState();
}

class _SitterProfileParentViewScreenState
    extends State<SitterProfileParentViewScreen> {
  bool _isStartingConversation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final parentProvider = context.read<ParentProvider>();
    await parentProvider.loadBabysitter(widget.babysitterId);
    if (!mounted) {
      return;
    }
    if (!parentProvider.isSaved(widget.babysitterId)) {
      await parentProvider.loadSavedSitters();
      if (!mounted) {
        return;
      }
    }
    await _handleUnauthorized(parentProvider.lastStatusCode);
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

  String _formatRate(BabysitterProfile sitter) {
    final amount = sitter.rateAmount;
    final currency = (sitter.currency ?? 'UGX').trim();
    final rateType = (sitter.rateType ?? 'hourly').trim();

    if (amount == null) {
      return 'Rate not set';
    }

    final amountText = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$amountText $currency/$rateType';
  }

  Future<void> _toggleSaved(BabysitterProfile sitter) async {
    final parentProvider = context.read<ParentProvider>();
    final success = await parentProvider.toggleSavedSitter(sitter);

    if (!mounted) {
      return;
    }

    if (!success) {
      await _handleUnauthorized(parentProvider.lastStatusCode);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            parentProvider.errorMessage ??
                'Unable to update your saved sitters right now.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(parentProvider.successMessage ?? 'Saved list updated.'),
      ),
    );
  }

  Future<void> _startConversation(BabysitterProfile sitter) async {
    if (_isStartingConversation) {
      return;
    }

    setState(() {
      _isStartingConversation = true;
    });

    final conversationsProvider = context.read<ConversationsProvider>();
    final conversation = await conversationsProvider.startConversation(
      sitter.id,
    );

    if (!mounted) {
      return;
    }

    if (conversation == null) {
      setState(() {
        _isStartingConversation = false;
      });
      await _handleUnauthorized(conversationsProvider.lastStatusCode);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            conversationsProvider.errorMessage ??
                'Unable to start a conversation right now.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isStartingConversation = false;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParentChatThreadScreen(
          conversationId: conversation.id,
          title: sitter.fullName,
          subtitle:
              (conversation.participantOccupation ??
                      conversation.participantRole ??
                      'Babysitter')
                  .trim(),
          avatarUrl: sitter.profilePictureUrl,
          phoneNumber: sitter.phone,
          participantProfile: sitter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        final sitter = parentProvider.selectedSitter;
        final isSaved = sitter != null && parentProvider.isSaved(sitter.id);

        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(
                      isSaved: isSaved,
                      onSavePressed: sitter == null
                          ? null
                          : () => _toggleSaved(sitter),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadProfile,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          child: _buildBody(parentProvider, sitter),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (sitter != null)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: _buildMessageButton(sitter),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ParentProvider parentProvider, BabysitterProfile? sitter) {
    if (parentProvider.isLoadingSelectedSitter && sitter == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (parentProvider.errorMessage != null && sitter == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Center(
          child: Column(
            children: [
              Text(
                parentProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadProfile,
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

    if (sitter == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildAvatarSection(sitter)),
        const SizedBox(height: 32),
        _buildInfoCard(sitter),
        const SizedBox(height: 32),
        _buildStatusSection(sitter),
        const SizedBox(height: 16),
        _buildAvailabilitySection(sitter),
        const SizedBox(height: 16),
        _buildLanguagesSection(sitter),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHeader({
    required bool isSaved,
    required VoidCallback? onSavePressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Sitter Profile',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: BabyCareTheme.primaryBerry,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back,
                color: BabyCareTheme.primaryBerry,
                size: 24,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: onSavePressed,
              child: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline,
                color: BabyCareTheme.primaryBerry,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BabysitterProfile sitter) {
    final imageUrl = (sitter.profilePictureUrl ?? '').trim();

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: BabyCareTheme.primaryBerry, width: 4),
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/logo.png', fit: BoxFit.cover);
                    },
                  )
                : Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          sitter.fullName,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: BabyCareTheme.primaryBerry,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          sitter.email,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard(BabysitterProfile sitter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.4),
        border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Gender',
            value: (sitter.gender ?? '').trim().isEmpty
                ? 'Not specified'
                : sitter.gender!,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: (sitter.location ?? '').trim().isEmpty
                ? 'Location not provided'
                : sitter.location!,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.attach_money_outlined,
            label: 'Rate',
            value: _formatRate(sitter),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.call_outlined,
            label: 'Phone',
            value: (sitter.phone ?? '').trim().isEmpty
                ? 'Phone not provided'
                : sitter.phone!,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.payments_outlined,
            label: 'Payment Method',
            value: (sitter.paymentMethod ?? '').trim().isEmpty
                ? 'Payment method not provided'
                : sitter.paymentMethod!,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: BabyCareTheme.lightPink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: BabyCareTheme.primaryBerry, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: BabyCareTheme.darkGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(BabysitterProfile sitter) {
    final days = sitter.availability;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: BabyCareTheme.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (days.isEmpty)
            Text(
              'No availability has been shared yet.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days
                  .map(
                    (day) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: BabyCareTheme.lightPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: BabyCareTheme.primaryBerry,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BabysitterProfile sitter) {
    final status = sitter.status.trim().isEmpty ? 'unknown' : sitter.status;
    final availability = sitter.isAvailable == true
        ? 'Available now'
        : 'Unavailable';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusChip(
              label: 'Status',
              value: status[0].toUpperCase() + status.substring(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusChip(
              label: 'Availability',
              value: availability,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BabyCareTheme.universalWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: BabyCareTheme.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(BabysitterProfile sitter) {
    final languages = sitter.languages;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Languages',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: BabyCareTheme.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (languages.isEmpty)
            Text(
              'No languages listed yet.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: languages
                  .map(
                    (language) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: BabyCareTheme.lightPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        language,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: BabyCareTheme.primaryBerry,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageButton(BabysitterProfile sitter) {
    return Container(
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: BabyCareTheme.primaryBerry.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isStartingConversation ? null : () => _startConversation(sitter),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isStartingConversation)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    BabyCareTheme.universalWhite,
                  ),
                ),
              )
            else
              const Icon(
                Icons.message_rounded,
                color: BabyCareTheme.universalWhite,
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              _isStartingConversation
                  ? 'Opening chat...'
                  : 'Message ${sitter.fullName}',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: BabyCareTheme.universalWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
