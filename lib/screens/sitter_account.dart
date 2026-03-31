import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/babysitter_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/babysitter_dashboard_provider.dart';
import 'gateway_screen.dart';
import 'sitter_dashboard.dart';
import 'sitter_messages.dart';

class SitterAccountScreen extends StatefulWidget {
  const SitterAccountScreen({super.key});

  @override
  State<SitterAccountScreen> createState() => _SitterAccountScreenState();
}

class _SitterAccountScreenState extends State<SitterAccountScreen> {
  late TextEditingController _ratesController;
  late TextEditingController _locationController;
  late TextEditingController _paymentController;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late List<bool> _selectedDays;

  @override
  void initState() {
    super.initState();
    _ratesController = TextEditingController();
    _locationController = TextEditingController();
    _paymentController = TextEditingController();
    _selectedDays = List<bool>.filled(_days.length, false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _ratesController.dispose();
    _locationController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    final dashboardProvider = context.read<BabysitterDashboardProvider>();
    final profile = dashboardProvider.profile;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load profile details before saving.')),
      );
      return;
    }

    final availability = <String>[];
    for (var index = 0; index < _days.length; index++) {
      if (_selectedDays[index]) {
        availability.add(_days[index]);
      }
    }

    final success = await dashboardProvider.updateProfile(
      location: _locationController.text.trim(),
      rateType: (profile.rateType ?? 'hourly').trim(),
      rateAmount: (profile.rateAmount ?? 0).toString(),
      currency: (profile.currency ?? 'UGX').trim(),
      paymentMethod: _paymentController.text.trim(),
      availability: availability,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      await _handleUnauthorized(dashboardProvider.lastStatusCode);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dashboardProvider.errorMessage ??
                'Unable to update your profile right now.',
          ),
        ),
      );
      return;
    }

    _syncProfileToControllers(dashboardProvider.profile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          dashboardProvider.successMessage ?? 'Profile updated successfully!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadProfile() async {
    final dashboardProvider = context.read<BabysitterDashboardProvider>();
    await dashboardProvider.loadDashboard();
    if (!mounted) {
      return;
    }
    await _handleUnauthorized(dashboardProvider.lastStatusCode);
    if (!mounted) {
      return;
    }
    _syncProfileToControllers(dashboardProvider.profile);
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

  void _syncProfileToControllers(BabysitterProfile? profile) {
    if (profile == null) {
      return;
    }

    _ratesController.text = _formatRate(profile);
    _locationController.text = _displayOrFallback(
      profile.location,
      fallback: 'Location not set',
    );
    _paymentController.text = _displayOrFallback(
      profile.paymentMethod,
      fallback: 'Payment method not set',
    );
    _selectedDays = _mapAvailabilityDays(profile.availability);
  }

  String _displayOrFallback(String? value, {required String fallback}) {
    final trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _formatRate(BabysitterProfile profile) {
    final amount = profile.rateAmount;
    final currency = _displayOrFallback(profile.currency, fallback: 'UGX');
    final rateType = _displayOrFallback(profile.rateType, fallback: 'hourly');

    if (amount == null) {
      return 'Rate not set';
    }

    final amountText = amount % 1 == 0
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$amountText $currency/$rateType';
  }

  List<bool> _mapAvailabilityDays(List<String> availability) {
    if (availability.isEmpty) {
      return List<bool>.filled(_days.length, false);
    }

    final normalized = availability.map((day) => day.toLowerCase()).toSet();
    return _days.map((day) {
      final short = day.toLowerCase();
      final long = _dayLongName(day).toLowerCase();
      return normalized.contains(short) || normalized.contains(long);
    }).toList();
  }

  String _dayLongName(String shortDay) {
    switch (shortDay) {
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      case 'Sat':
        return 'Saturday';
      case 'Sun':
        return 'Sunday';
      default:
        return shortDay;
    }
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

  Widget _buildBodyContent(BabysitterDashboardProvider dashboardProvider) {
    final profile = dashboardProvider.profile;

    if (dashboardProvider.isLoading && profile == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 56),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (dashboardProvider.errorMessage != null && profile == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            Text(
              dashboardProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: BabyCareTheme.primaryBerry,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildAvatarSection(),
        const SizedBox(height: 32),
        _buildWorkPreferencesSection(),
        const SizedBox(height: 24),
        _buildCardSection(
          title: 'Preferred Payment Method',
          controller: _paymentController,
          icon: Icons.edit_outlined,
        ),
        const SizedBox(height: 32),
        _buildSaveButton(),
        const SizedBox(height: 16),
        _buildLogoutButton(),
        const SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BabysitterDashboardProvider>(
      builder: (context, dashboardProvider, _) {
        _syncProfileToControllers(dashboardProvider.profile);

        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          extendBody: true,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadProfile,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          child: _buildBodyContent(dashboardProvider),
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

  /// Header with back button
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar with camera overlay
  Widget _buildAvatarSection() {
    final profileImageUrl = context
        .watch<BabysitterDashboardProvider>()
        .profile
        ?.profilePictureUrl;

    return Column(
      children: [
        Stack(
          children: [
            // Avatar Container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: BabyCareTheme.primaryGradient,
                border: Border.all(color: BabyCareTheme.primaryBerry, width: 3),
              ),
              child: ClipOval(
                child: _buildProfileImage(profileImageUrl),
              ),
            ),
            // Camera Overlay
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera feature not yet implemented'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BabyCareTheme.primaryGradient,
                    border: Border.all(
                      color: BabyCareTheme.universalWhite,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: BabyCareTheme.darkGrey.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: BabyCareTheme.universalWhite,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _displayOrFallback(
            context.watch<BabysitterDashboardProvider>().profile?.fullName,
            fallback: 'Babysitter',
          ),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: BabyCareTheme.primaryBerry,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _displayOrFallback(
            context.watch<BabysitterDashboardProvider>().profile?.email,
            fallback: 'Professional Babysitter',
          ),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: BabyCareTheme.darkGrey.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Card section for editable fields
  Widget _buildCardSection({
    required String title,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.3),
        border: Border.all(color: BabyCareTheme.lightGrey, width: 2),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Edit $title'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(icon, color: BabyCareTheme.primaryBerry, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Card Content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: BabyCareTheme.universalWhite,
              border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              enabled: false,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: BabyCareTheme.darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  /// Work Preferences Section
  Widget _buildWorkPreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey.withValues(alpha: 0.3),
        border: Border.all(color: BabyCareTheme.lightGrey, width: 2),
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Work Preferences',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit Work Preferences'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(
                  Icons.edit_outlined,
                  color: BabyCareTheme.primaryBerry,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: BabyCareTheme.primaryBerry,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Available Days',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _days.length,
                  (index) => _selectedDays[index]
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BabyCareTheme.primaryBerry,
                            border: Border.all(
                              color: BabyCareTheme.primaryBerry,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _days[index],
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: BabyCareTheme.universalWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rates Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    color: BabyCareTheme.primaryBerry,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rates',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: BabyCareTheme.universalWhite,
                  border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _ratesController,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: BabyCareTheme.primaryBerry,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: BabyCareTheme.universalWhite,
                  border: Border.all(color: BabyCareTheme.lightGrey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _locationController,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Save Changes Button
  Widget _buildSaveButton() {
    final isSaving = context
        .watch<BabysitterDashboardProvider>()
        .isUpdatingProfile;

    return GestureDetector(
      onTap: isSaving ? null : _onSavePressed,
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
        child: isSaving
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      BabyCareTheme.universalWhite,
                    ),
                  ),
                ),
              )
            : Text(
                'Save Changes',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: BabyCareTheme.universalWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  /// Logout Button
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: BabyCareTheme.universalWhite,
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: BabyCareTheme.primaryBerry,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: BabyCareTheme.darkGrey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: BabyCareTheme.darkGrey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const GatewayScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: BabyCareTheme.primaryBerry),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: BabyCareTheme.primaryBerry, width: 2),
          borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        ),
        child: Text(
          'Logout',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: BabyCareTheme.primaryBerry,
            fontWeight: FontWeight.bold,
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
                isActive: false,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const SitterMessagesScreen(),
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
