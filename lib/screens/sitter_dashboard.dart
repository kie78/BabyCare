import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'sitter_messages.dart';
import 'sitter_account.dart';
import 'parent_profile_sitter_view.dart';

class SitterDashboardScreen extends StatefulWidget {
  const SitterDashboardScreen({super.key});

  @override
  State<SitterDashboardScreen> createState() => _SitterDashboardScreenState();
}

class _SitterDashboardScreenState extends State<SitterDashboardScreen> {
  bool _isAvailable = true;
  final int _weeklyReach = 127;

  final List<_Visitor> visitors = [
    _Visitor(
      name: 'Sarah M.',
      profileImage: 'assets/logo.png',
      message: 'Interested in your profile',
      timestamp: '2 hours ago',
      occupation: 'Nurse',
    ),
    _Visitor(
      name: 'James K.',
      profileImage: 'assets/logo.png',
      message: 'Would like to book you',
      timestamp: '4 hours ago',
      occupation: 'Engineer',
    ),
    _Visitor(
      name: 'Emma L.',
      profileImage: 'assets/logo.png',
      message: 'Viewed your availability',
      timestamp: '1 day ago',
      occupation: 'Teacher',
    ),
  ];

  void _onAvailabilityToggle(bool value) {
    setState(() {
      _isAvailable = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You are now ${_isAvailable ? 'available' : 'unavailable'}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onMessagesPressed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SitterMessagesScreen()),
    );
  }

  void _onVisitorPressed(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParentProfileSitterViewScreen(
          parentName: visitors[index].name,
          location: 'Kampala',
          job: visitors[index].occupation,
          hours: '4PM–9PM',
        ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: _buildHeader(),
                ),
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Availability toggle card
                        _buildAvailabilityCard(),

                        const SizedBox(height: 24),

                        // Weekly reach metric
                        _buildWeeklyReachCard(),

                        const SizedBox(height: 32),

                        // Visitors section
                        _buildVisitorsSection(),

                        const SizedBox(height: 100),
                      ],
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
  }

  /// Header with greeting and avatar
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hello, Maria',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            color: BabyCareTheme.primaryBerry,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BabyCareTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: BabyCareTheme.primaryBerry.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  /// Availability toggle card
  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isAvailable ? BabyCareTheme.lightPink : BabyCareTheme.lightGrey,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        border: Border.all(
          color: _isAvailable
              ? BabyCareTheme.primaryBerry.withValues(alpha: 0.2)
              : BabyCareTheme.lightGrey,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Work Status',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: BabyCareTheme.darkGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isAvailable ? 'You are available' : 'You are unavailable',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: _isAvailable
                      ? BabyCareTheme.primaryBerry
                      : BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Switch(
            value: _isAvailable,
            onChanged: _onAvailabilityToggle,
            activeColor: BabyCareTheme.primaryBerry,
            activeTrackColor: BabyCareTheme.primaryBerry.withValues(alpha: 0.3),
            inactiveThumbColor: BabyCareTheme.darkGrey.withValues(alpha: 0.3),
            inactiveTrackColor: BabyCareTheme.darkGrey.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  /// Weekly reach metric card
  Widget _buildWeeklyReachCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightPurple,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        border: Border.all(color: BabyCareTheme.lightPurple),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BabyCareTheme.primaryGradient,
            ),
            child: const Icon(
              Icons.bar_chart,
              color: BabyCareTheme.universalWhite,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Reach',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_weeklyReach parents viewed your profile',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: BabyCareTheme.primaryBerry,
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

  /// Visitors section
  Widget _buildVisitorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Visitors',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: BabyCareTheme.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visitors.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final visitor = visitors[index];
            return GestureDetector(
              onTap: () => _onVisitorPressed(index),
              child: _buildVisitorCard(visitor),
            );
          },
        ),
      ],
    );
  }

  /// Individual visitor card
  Widget _buildVisitorCard(_Visitor visitor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        border: Border.all(color: BabyCareTheme.lightGrey),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BabyCareTheme.primaryGradient,
            ),
            child: ClipOval(
              child: Image.asset(visitor.profileImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.name,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  visitor.occupation,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Timestamp
          Text(
            visitor.timestamp,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
              fontSize: 11,
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
                isActive: true,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.message_outlined,
                label: 'Messages',
                isActive: false,
                onTap: _onMessagesPressed,
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

/// Visitor data model
class _Visitor {
  final String name;
  final String profileImage;
  final String message;
  final String timestamp;
  final String occupation;

  _Visitor({
    required this.name,
    required this.profileImage,
    required this.message,
    required this.timestamp,
    required this.occupation,
  });
}
