import 'package:flutter/material.dart';
import '../config/theme.dart';

class ParentProfileSitterViewScreen extends StatefulWidget {
  final String parentName;
  final String profileImage;
  final String location;
  final String job;
  final String hours;
  final String phoneNumber;

  const ParentProfileSitterViewScreen({
    super.key,
    this.parentName = 'Sarah Namukasa',
    this.profileImage = 'assets/logo.png',
    this.location = 'Kansanga',
    this.job = 'Nurse',
    this.hours = '4PM–9PM',
    this.phoneNumber = '+256 7** *** *89',
  });

  @override
  State<ParentProfileSitterViewScreen> createState() =>
      _ParentProfileSitterViewScreenState();
}

class _ParentProfileSitterViewScreenState
    extends State<ParentProfileSitterViewScreen> {
  void _onContinueChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening chat with parent...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onPhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling parent...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Profile Identity Section
                  _buildProfileSection(),

                  // Information Cards Section
                  _buildInformationCards(),

                  // Contact Card
                  _buildContactCard(),
                ],
              ),
            ),
            // Action Button
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with title and back button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Parent Profile',
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
        ],
      ),
    );
  }

  /// Profile Identity Section with avatar and name
  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BabyCareTheme.primaryGradient,
              border: Border.all(color: BabyCareTheme.primaryBerry, width: 4),
            ),
            child: ClipOval(
              child: Image.asset(widget.profileImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            widget.parentName,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: BabyCareTheme.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Information Cards (Location, Job, Hours)
  Widget _buildInformationCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildInfoCard(
            icon: Icons.location_on,
            label: 'LOCATION',
            value: widget.location,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.work,
            label: 'OCCUPATION',
            value: widget.job,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.schedule,
            label: 'HOURS',
            value: widget.hours,
          ),
        ],
      ),
    );
  }

  /// Individual Info Card
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
      ),
      child: Row(
        children: [
          // Icon
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
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.primaryBerry,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Contact Card with phone
  Widget _buildContactCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BabyCareTheme.universalWhite,
          borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
          border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHONE NUMBER',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.primaryBerry,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.phoneNumber,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Phone Call Button
            GestureDetector(
              onTap: _onPhoneCall,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BabyCareTheme.lightPink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.call,
                  color: BabyCareTheme.primaryBerry,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Continue Chat Action Button
  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _onContinueChat,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: BabyCareTheme.universalWhite,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Continue Chat',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: BabyCareTheme.universalWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
