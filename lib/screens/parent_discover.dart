import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'parent_messages.dart';
import 'parent_account.dart';
import 'sitter_profile_parent_view.dart';

class ParentDiscoverScreen extends StatefulWidget {
  const ParentDiscoverScreen({super.key});

  @override
  State<ParentDiscoverScreen> createState() => _ParentDiscoverScreenState();
}

class _ParentDiscoverScreenState extends State<ParentDiscoverScreen> {
  late TextEditingController _searchController;
  late Set<int> _bookmarkedSitters;

  final List<_SitterCard> sitters = const [
    _SitterCard(
      name: 'Maria Elena',
      gender: 'Female',
      rate: '15,000 UGX/hr',
      location: 'Kampala, Uganda',
      isVerified: true,
    ),
    _SitterCard(
      name: 'Grace Okello',
      gender: 'Female',
      rate: '12,000 UGX/hr',
      location: 'Kololo, Kampala',
      isVerified: true,
    ),
    _SitterCard(
      name: 'Amina Hassan',
      gender: 'Female',
      rate: '18,000 UGX/hr',
      location: 'Makindye, Kampala',
      isVerified: true,
    ),
    _SitterCard(
      name: 'Sarah Namukasa',
      gender: 'Female',
      rate: '14,000 UGX/hr',
      location: 'Ntinda, Kampala',
      isVerified: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bookmarkedSitters = {};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter & Location feature coming soon')),
    );
  }

  void _onSitterCardPressed(_SitterCard sitter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SitterProfileParentViewScreen(
          sitterName: sitter.name,
          gender: sitter.gender,
          location: sitter.location,
          rate: sitter.rate,
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
                // Header
                _buildHeader(),

                // Search Bar
                _buildSearchBar(),

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
                        // Available Sitters Header
                        _buildSectionHeader(),

                        const SizedBox(height: 16),

                        // Sitter Cards List
                        ...List.generate(
                          sitters.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSitterCard(sitters[index]),
                          ),
                        ),

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

  /// Header with title and profile thumbnail
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: BabyCareTheme.primaryBerry, width: 2),
            ),
            child: ClipOval(
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  /// Search bar with filter button
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a sitter...',
                hintStyle: TextStyle(
                  color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: BabyCareTheme.darkGrey,
                ),
                filled: true,
                fillColor: BabyCareTheme.lightGrey,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusLarge,
                  ),
                  borderSide: const BorderSide(color: BabyCareTheme.lightGrey),
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
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onFilterPressed,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: BabyCareTheme.primaryBerry,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: BabyCareTheme.universalWhite,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section header
  Widget _buildSectionHeader() {
    return Text(
      'Available Sitters',
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: BabyCareTheme.darkGrey,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Sitter card in list
  Widget _buildSitterCard(_SitterCard sitter) {
    int sitterIndex = sitters.indexOf(sitter);
    bool isBookmarked = _bookmarkedSitters.contains(sitterIndex);

    return GestureDetector(
      onTap: () => _onSitterCardPressed(sitter),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BabyCareTheme.lightGrey.withValues(alpha: 0.5),
          border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Left Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    sitter.name,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Gender
                  Text(
                    sitter.gender,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rate in Bold Magenta
                  Text(
                    sitter.rate,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: BabyCareTheme.primaryBerry,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location on its own row
                  Text(
                    sitter.location,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Right: Avatar with Bookmark
            Stack(
              children: [
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
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isBookmarked) {
                          _bookmarkedSitters.remove(sitterIndex);
                        } else {
                          _bookmarkedSitters.add(sitterIndex);
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? 'Removed ${sitter.name}'
                                : 'Saved ${sitter.name}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BabyCareTheme.universalWhite,
                        border: Border.all(
                          color: BabyCareTheme.lightGrey,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline,
                        color: isBookmarked
                            ? BabyCareTheme.primaryBerry
                            : BabyCareTheme.primaryBerry,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        border: Border.all(color: BabyCareTheme.lightGrey, width: 2),
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
                isActive: true,
                onTap: () {},
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

/// Data class for sitter card
class _SitterCard {
  final String name;
  final String gender;
  final String rate;
  final String location;
  final bool isVerified;

  const _SitterCard({
    required this.name,
    required this.gender,
    required this.rate,
    required this.location,
    required this.isVerified,
  });
}
