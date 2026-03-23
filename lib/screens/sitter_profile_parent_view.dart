import 'package:flutter/material.dart';
import '../config/theme.dart';

class SitterProfileParentViewScreen extends StatefulWidget {
  final String sitterName;
  final String gender;
  final String location;
  final String rate;

  const SitterProfileParentViewScreen({
    super.key,
    required this.sitterName,
    required this.gender,
    required this.location,
    required this.rate,
  });

  @override
  State<SitterProfileParentViewScreen> createState() =>
      _SitterProfileParentViewScreenState();
}

class _SitterProfileParentViewScreenState
    extends State<SitterProfileParentViewScreen> {
  bool _isSaved = false;
  final List<String> _availableDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> _languages = ['English', 'Luganda'];

  void _onHeartPressed() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved ? 'Saved ${widget.sitterName}' : 'Removed from saved',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onMessagePressed() {
    // TODO: Navigate to chat thread with this sitter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message ${widget.sitterName} (feature coming soon)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Section (centered)
                        Center(child: _buildAvatarSection()),

                        const SizedBox(height: 32),

                        // Info Card
                        _buildInfoCard(),

                        const SizedBox(height: 32),

                        // Availability Section
                        _buildAvailabilitySection(),

                        const SizedBox(height: 16),

                        // Languages Section
                        _buildLanguagesSection(),

                        const SizedBox(height: 100), // Space for button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Message Button at Bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildMessageButton(),
          ),
        ],
      ),
    );
  }

  /// Header with back arrow and heart save icon
  Widget _buildHeader() {
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
              onTap: _onHeartPressed,
              child: Icon(
                _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline,
                color: BabyCareTheme.primaryBerry,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar with name section
  Widget _buildAvatarSection() {
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
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.sitterName,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: BabyCareTheme.primaryBerry,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Info card with metadata
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.4),
        border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Column(
        children: [
          // Gender Row
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Gender',
            value: widget.gender,
          ),
          const SizedBox(height: 16),

          // Location Row
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: widget.location,
          ),
          const SizedBox(height: 16),

          // Rate Row
          _buildInfoRow(
            icon: Icons.attach_money_outlined,
            label: 'Rate',
            value: widget.rate,
          ),
        ],
      ),
    );
  }

  /// Individual info row
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

  /// Availability section with day pills
  Widget _buildAvailabilitySection() {
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _availableDays.length,
              (index) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BabyCareTheme.lightPink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _availableDays[index],
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.primaryBerry,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Languages section
  Widget _buildLanguagesSection() {
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _languages.length,
              (index) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BabyCareTheme.lightPink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _languages[index],
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.primaryBerry,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Message button at bottom
  Widget _buildMessageButton() {
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
        onPressed: _onMessagePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.message_rounded,
              color: BabyCareTheme.universalWhite,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Message ${widget.sitterName}',
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
