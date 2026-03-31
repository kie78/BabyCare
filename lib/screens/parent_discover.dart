import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/babysitter_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/parent_provider.dart';
import 'gateway_screen.dart';
import 'parent_account.dart';
import 'parent_messages.dart';
import 'sitter_profile_parent_view.dart';

class ParentDiscoverScreen extends StatefulWidget {
  const ParentDiscoverScreen({super.key});

  @override
  State<ParentDiscoverScreen> createState() => _ParentDiscoverScreenState();
}

class _ParentDiscoverScreenState extends State<ParentDiscoverScreen> {
  late final TextEditingController _searchController;
  String? _pendingBookmarkSitterId;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    context.read<ParentProvider>().setSearchQuery(_searchController.text);
  }

  Future<void> _loadData() async {
    final parentProvider = context.read<ParentProvider>();
    await parentProvider.loadSitters();
    if (!mounted) {
      return;
    }
    await parentProvider.loadSavedSitters();
    if (!mounted) {
      return;
    }
    if (parentProvider.profile == null) {
      await parentProvider.loadParentProfile(silent: true);
      if (!mounted) {
        return;
      }
    }
    await _handleUnauthorized(parentProvider);
  }

  Future<void> _handleUnauthorized(ParentProvider parentProvider) async {
    if (parentProvider.lastStatusCode != 401 &&
        parentProvider.lastStatusCode != 403) {
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

  String _displayLocation(BabysitterProfile sitter) {
    final location = (sitter.location ?? '').trim();
    return location.isEmpty ? 'Location not provided' : location;
  }

  List<String> _availableLocations(List<BabysitterProfile> sitters) {
    final uniqueLocations = <String>[];
    final seenLocations = <String>{};

    for (final sitter in sitters) {
      final normalizedLocation = (sitter.location ?? '').trim();
      if (normalizedLocation.isEmpty) {
        continue;
      }

      final key = normalizedLocation.toLowerCase();
      if (seenLocations.add(key)) {
        uniqueLocations.add(normalizedLocation);
      }
    }

    uniqueLocations.sort((first, second) => first.compareTo(second));
    return uniqueLocations;
  }

  List<BabysitterProfile> _applyLocationFilter(List<BabysitterProfile> sitters) {
    final selectedLocation = (_selectedLocation ?? '').trim().toLowerCase();
    if (selectedLocation.isEmpty) {
      return sitters;
    }

    return sitters.where((sitter) {
      return (sitter.location ?? '').trim().toLowerCase() == selectedLocation;
    }).toList();
  }

  Widget _buildProfileImage(String? imageUrl, {double size = 64}) {
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

  Widget _buildCurrentUserAvatar(String? imageUrl) {
    final normalizedUrl = (imageUrl ?? '').trim();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: BabyCareTheme.primaryBerry, width: 2),
      ),
      child: ClipOval(
        child: normalizedUrl.isEmpty
            ? Image.asset('assets/logo.png', fit: BoxFit.cover)
            : Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/logo.png', fit: BoxFit.cover);
                },
              ),
      ),
    );
  }

  Future<void> _toggleSave(BabysitterProfile sitter) async {
    if (_pendingBookmarkSitterId == sitter.id) {
      return;
    }

    setState(() {
      _pendingBookmarkSitterId = sitter.id;
    });

    final parentProvider = context.read<ParentProvider>();
    final success = await parentProvider.toggleSavedSitter(sitter);

    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _pendingBookmarkSitterId = null;
      });
      await _handleUnauthorized(parentProvider);
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

    await parentProvider.loadSavedSitters();
    if (!mounted) {
      return;
    }

    setState(() {
      _pendingBookmarkSitterId = null;
    });

    await _handleUnauthorized(parentProvider);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(parentProvider.successMessage ?? 'Saved updated.'),
      ),
    );
  }

  Future<void> _onFilterPressed() async {
    final parentProvider = context.read<ParentProvider>();
    final locations = _availableLocations(parentProvider.sitters);

    if (locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sitter locations are available yet.'),
        ),
      );
      return;
    }

    final selectedLocation = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: BabyCareTheme.universalWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by location',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Show sitters from a specific location.',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLocationOption(
                  label: 'All locations',
                  isSelected: (_selectedLocation ?? '').trim().isEmpty,
                  onTap: () => Navigator.of(context).pop(''),
                ),
                const SizedBox(height: 8),
                ...locations.map(
                  (location) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildLocationOption(
                      label: location,
                      isSelected:
                          location.toLowerCase() ==
                          (_selectedLocation ?? '').trim().toLowerCase(),
                      onTap: () => Navigator.of(context).pop(location),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selectedLocation == null) {
      return;
    }

    setState(() {
      _selectedLocation = selectedLocation.trim().isEmpty
          ? null
          : selectedLocation;
    });
  }

  Widget _buildLocationOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? BabyCareTheme.lightPink.withValues(alpha: 0.5)
                : BabyCareTheme.lightGrey.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? BabyCareTheme.primaryBerry
                  : BabyCareTheme.lightGrey,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: BabyCareTheme.primaryBerry,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSitterCardPressed(BabysitterProfile sitter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SitterProfileParentViewScreen(babysitterId: sitter.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        final sitters = _applyLocationFilter(parentProvider.filteredSitters);

        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          extendBody: true,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(parentProvider),
                    _buildSearchBar(),
                    if ((_selectedLocation ?? '').trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLocation = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: BabyCareTheme.lightPink,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: BabyCareTheme.primaryBerry,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedLocation!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(
                                      color: BabyCareTheme.primaryBerry,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.close,
                                    color: BabyCareTheme.primaryBerry,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(),
                              const SizedBox(height: 16),
                              if (parentProvider.isLoadingSitters &&
                                  sitters.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 64),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (parentProvider.errorMessage != null &&
                                  sitters.isEmpty)
                                _buildErrorState(parentProvider)
                              else if (sitters.isEmpty)
                                _buildEmptyState()
                              else
                                ...sitters.map(
                                  (sitter) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildSitterCard(
                                      sitter,
                                      isBookmarked: parentProvider.isSaved(
                                        sitter.id,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 100),
                            ],
                          ),
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

  Widget _buildHeader(ParentProvider parentProvider) {
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
          _buildCurrentUserAvatar(parentProvider.profile?.profilePictureUrl),
        ],
      ),
    );
  }

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
                color: (_selectedLocation ?? '').trim().isEmpty
                    ? BabyCareTheme.primaryBerry
                    : BabyCareTheme.lightPink,
                shape: BoxShape.circle,
                border: (_selectedLocation ?? '').trim().isEmpty
                    ? null
                    : Border.all(
                        color: BabyCareTheme.primaryBerry,
                        width: 1.5,
                      ),
              ),
              child: Icon(
                Icons.location_on,
                color: (_selectedLocation ?? '').trim().isEmpty
                    ? BabyCareTheme.universalWhite
                    : BabyCareTheme.primaryBerry,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Text(
      'Available Sitters',
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: BabyCareTheme.darkGrey,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildErrorState(ParentProvider parentProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Text(
              parentProvider.errorMessage ?? 'Unable to load sitters.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Text(
          'No sitters match your current search.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildSitterCard(
    BabysitterProfile sitter, {
    required bool isBookmarked,
  }) {
    final isBookmarkUpdating = _pendingBookmarkSitterId == sitter.id;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sitter.fullName,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (sitter.gender ?? 'Not specified').trim().isEmpty
                        ? 'Not specified'
                        : sitter.gender!,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRate(sitter),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: BabyCareTheme.primaryBerry,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displayLocation(sitter),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                    ),
                  ),
                  if ((sitter.languages).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      sitter.languages.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
                    child: _buildProfileImage(
                      sitter.profilePictureUrl,
                      size: 64,
                    ),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: GestureDetector(
                    onTap: () => _toggleSave(sitter),
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
                      child: isBookmarkUpdating
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  BabyCareTheme.primaryBerry,
                                ),
                              ),
                            )
                          : Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline,
                              color: BabyCareTheme.primaryBerry,
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
