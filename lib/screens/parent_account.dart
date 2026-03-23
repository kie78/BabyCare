import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'parent_discover.dart';
import 'parent_messages.dart';
import 'parent_login.dart';
import 'sitter_profile_parent_view.dart';

class ParentAccountScreen extends StatefulWidget {
  const ParentAccountScreen({super.key});

  @override
  State<ParentAccountScreen> createState() => _ParentAccountScreenState();
}

class _ParentAccountScreenState extends State<ParentAccountScreen> {
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
                // Header
                _buildHeader(),

                // Menu Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // My Profile Card
                        _buildMenuCard(
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          subtitle: 'Edit your personal information',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ParentProfileEditScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Saved Sitters Card
                        _buildMenuCard(
                          icon: Icons.bookmark_outline,
                          title: 'Saved Sitters',
                          subtitle: 'View your bookmarked sitters',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ParentSavedSittersScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Log Out Button
                        _buildLogOutButton(),

                        const SizedBox(height: 100), // Space for bottom nav
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

  /// Account header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        'Account',
        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
          color: BabyCareTheme.primaryBerry,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Menu card for account options
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BabyCareTheme.lightGrey.withValues(alpha: 0.4),
          border: Border.all(color: BabyCareTheme.lightGrey, width: 2),
          borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: BabyCareTheme.lightPink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: BabyCareTheme.primaryBerry,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Text content
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }

  /// Log Out button
  Widget _buildLogOutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ParentLoginScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Log Out',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: BabyCareTheme.universalWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
                isActive: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ParentMessagesScreen(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.person_outline,
                label: 'Account',
                isActive: true,
                onTap: () {},
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

/// Parent Profile Edit Screen
class ParentProfileEditScreen extends StatefulWidget {
  const ParentProfileEditScreen({super.key});

  @override
  State<ParentProfileEditScreen> createState() =>
      _ParentProfileEditScreenState();
}

class _ParentProfileEditScreenState extends State<ParentProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _occupationController;
  late TextEditingController _hoursController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Sarah Johnson');
    _occupationController = TextEditingController(text: 'Marketing Manager');
    _hoursController = TextEditingController(text: '9AM - 5PM');
    _phoneController = TextEditingController(text: '+256 701 234567');
    _locationController = TextEditingController(text: 'Kampala, Uganda');
    _emailController = TextEditingController(text: 'sarah@email.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _occupationController.dispose();
    _hoursController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    super.dispose();
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Avatar Section
                    _buildAvatarSection(),

                    const SizedBox(height: 32),

                    // Form Fields
                    _buildFormField(
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 12),

                    _buildFormField(
                      label: 'Occupation',
                      icon: Icons.work_outline,
                      controller: _occupationController,
                    ),
                    const SizedBox(height: 12),

                    _buildFormField(
                      label: 'Preferred Hours',
                      icon: Icons.schedule_outlined,
                      controller: _hoursController,
                    ),
                    const SizedBox(height: 12),

                    _buildFormField(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 12),

                    _buildFormField(
                      label: 'Primary Location',
                      icon: Icons.location_on_outlined,
                      controller: _locationController,
                    ),
                    const SizedBox(height: 12),

                    _buildFormField(
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    _buildSaveButton(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with back arrow
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
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
          const SizedBox(width: 16),
          Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: BabyCareTheme.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar with Camera overlay
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: BabyCareTheme.primaryBerry,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BabyCareTheme.primaryBerry,
                border: Border.all(
                  color: BabyCareTheme.universalWhite,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: BabyCareTheme.universalWhite,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Form field with icon and edit styling
  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
      ),
      child: Row(
        children: [
          // Left icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BabyCareTheme.lightPink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: BabyCareTheme.primaryBerry,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BabyCareTheme.darkGrey,
              ),
            ),
          ),

          // Edit icon
          Icon(
            Icons.edit_outlined,
            color: BabyCareTheme.primaryBerry,
            size: 18,
          ),
        ],
      ),
    );
  }

  /// Save Changes button
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          },
          borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Save Changes',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: BabyCareTheme.universalWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Parent Saved Sitters Screen
class ParentSavedSittersScreen extends StatefulWidget {
  const ParentSavedSittersScreen({super.key});

  @override
  State<ParentSavedSittersScreen> createState() =>
      _ParentSavedSittersScreenState();
}

class _ParentSavedSittersScreenState extends State<ParentSavedSittersScreen> {
  late List<_SavedSitter> savedSitters = [
    _SavedSitter(
      name: 'Maria Elena',
      gender: 'Female',
      rate: '15,000 UGX/hr',
      location: 'Kampala, Uganda',
    ),
    _SavedSitter(
      name: 'Grace Okello',
      gender: 'Female',
      rate: '12,000 UGX/hr',
      location: 'Kololo, Kampala',
    ),
    _SavedSitter(
      name: 'Sarah Namukasa',
      gender: 'Female',
      rate: '14,000 UGX/hr',
      location: 'Ntinda, Kampala',
    ),
  ];

  void _showRemoveDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Sitter?',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: BabyCareTheme.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${savedSitters[index].name} from your saved sitters?',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BabyCareTheme.primaryBerry,
            ),
            onPressed: () {
              setState(() {
                savedSitters.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${savedSitters.length < 3 ? '' : ''}Removed from saved'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              'Yes',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BabyCareTheme.universalWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                // Header with back arrow
                _buildHeader(),

                // Saved Sitters List
                Expanded(
                  child: savedSitters.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                          itemCount: savedSitters.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SitterProfileParentViewScreen(
                                      sitterName: savedSitters[index].name,
                                      gender: savedSitters[index].gender,
                                      location: savedSitters[index].location,
                                      rate: savedSitters[index].rate,
                                    ),
                                  ),
                                );
                              },
                              child: _buildSitterCard(
                                savedSitters[index],
                                index,
                              ),
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

  /// Header with back arrow
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
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
          const SizedBox(width: 16),
          Text(
            'Saved Sitters',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.bold,
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
            Icons.bookmark_outline,
            size: 64,
            color: BabyCareTheme.primaryBerry.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved sitters yet',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Sitter card with bookmark at bottom right
  Widget _buildSitterCard(_SavedSitter sitter, int index) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BabyCareTheme.lightGrey.withValues(alpha: 0.5),
            border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: BabyCareTheme.primaryBerry,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sitter.name,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: BabyCareTheme.darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sitter.gender,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sitter.rate,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: BabyCareTheme.primaryBerry,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sitter.location,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bookmark icon at bottom right
        Positioned(
          right: 8,
          bottom: 8,
          child: GestureDetector(
            onTap: () => _showRemoveDialog(index),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BabyCareTheme.universalWhite,
                border: Border.all(
                  color: BabyCareTheme.lightGrey,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: BabyCareTheme.primaryBerry,
                size: 18,
              ),
            ),
          ),
        ),
      ],
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
                isActive: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const ParentMessagesScreen(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildNavItem(
                icon: Icons.person_outline,
                label: 'Account',
                isActive: true,
                onTap: () {},
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

/// Saved sitter data model
class _SavedSitter {
  final String name;
  final String gender;
  final String rate;
  final String location;

  _SavedSitter({
    required this.name,
    required this.gender,
    required this.rate,
    required this.location,
  });
}
