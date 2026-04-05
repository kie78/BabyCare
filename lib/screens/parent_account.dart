import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/babysitter_profile.dart';
import '../models/parent_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/parent_provider.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_toast.dart';
import 'gateway_screen.dart';
import 'parent_discover.dart';
import 'parent_messages.dart';
import 'sitter_profile_parent_view.dart';

class ParentAccountScreen extends StatefulWidget {
  const ParentAccountScreen({super.key});

  @override
  State<ParentAccountScreen> createState() => _ParentAccountScreenState();
}

class _ParentAccountScreenState extends State<ParentAccountScreen> {
  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const GatewayScreen()),
      (route) => false,
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
              child: Icon(icon, color: BabyCareTheme.primaryBerry, size: 28),
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
          onTap: _logout,
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
  late FocusNode _nameFocusNode;
  late FocusNode _occupationFocusNode;
  late FocusNode _hoursFocusNode;
  late FocusNode _phoneFocusNode;
  late FocusNode _locationFocusNode;
  late FocusNode _emailFocusNode;
  ParentProfile? _initialProfile;
  String? _selectedProfileImagePath;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _occupationController = TextEditingController();
    _hoursController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _emailController = TextEditingController();
    _nameFocusNode = FocusNode();
    _occupationFocusNode = FocusNode();
    _hoursFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _locationFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _nameController.addListener(_updateHasChanges);
    _occupationController.addListener(_updateHasChanges);
    _hoursController.addListener(_updateHasChanges);
    _phoneController.addListener(_updateHasChanges);
    _locationController.addListener(_updateHasChanges);
    _emailController.addListener(_updateHasChanges);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateHasChanges);
    _occupationController.removeListener(_updateHasChanges);
    _hoursController.removeListener(_updateHasChanges);
    _phoneController.removeListener(_updateHasChanges);
    _locationController.removeListener(_updateHasChanges);
    _emailController.removeListener(_updateHasChanges);
    _nameController.dispose();
    _occupationController.dispose();
    _hoursController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _occupationFocusNode.dispose();
    _hoursFocusNode.dispose();
    _phoneFocusNode.dispose();
    _locationFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  String _normalizeValue(String? value) {
    return (value ?? '').trim();
  }

  ParentProfile? _fallbackProfileFromSession() {
    final authUser = context.read<AuthProvider>().currentUser;
    if (authUser == null) {
      return null;
    }

    return ParentProfile(
      id: authUser.id,
      fullName: authUser.fullName,
      email: authUser.email,
      occupation: '',
      preferredHours: '',
      phone: authUser.phone,
      location: '',
      primaryLocation: '',
      status: authUser.status,
    );
  }

  void _updateHasChanges() {
    final initialProfile = _initialProfile;
    if (initialProfile == null) {
      if (_hasChanges) {
        setState(() {
          _hasChanges = false;
        });
      }
      return;
    }

    final fieldsChanged = _normalizeValue(_nameController.text) !=
            _normalizeValue(initialProfile.fullName) ||
        _normalizeValue(_occupationController.text) !=
            _normalizeValue(initialProfile.occupation) ||
        _normalizeValue(_hoursController.text) !=
            _normalizeValue(initialProfile.preferredHours) ||
        _normalizeValue(_phoneController.text) !=
            _normalizeValue(initialProfile.phone) ||
        _normalizeValue(_locationController.text) !=
            _normalizeValue(
              initialProfile.primaryLocation ?? initialProfile.location,
            ) ||
        _normalizeValue(_emailController.text) !=
            _normalizeValue(initialProfile.email);

    final imageChanged = _normalizeValue(_selectedProfileImagePath).isNotEmpty;

    final nextHasChanges = fieldsChanged || imageChanged;
    if (nextHasChanges == _hasChanges) {
      return;
    }

    setState(() {
      _hasChanges = nextHasChanges;
    });
  }

  void _syncFormWithProfile(ParentProfile profile) {
    _initialProfile = profile;
    _nameController.text = profile.fullName;
    _occupationController.text = profile.occupation;
    _hoursController.text = profile.preferredHours;
    _phoneController.text = profile.phone ?? '';
    _locationController.text = profile.primaryLocation ?? profile.location ?? '';
    _emailController.text = profile.email;
    _selectedProfileImagePath = null;
    _updateHasChanges();
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final path = file.path;
    if (path == null || path.trim().isEmpty) {
      AppToast.showError(context, 'Unable to access the selected image. Try again.');
      return;
    }

    setState(() {
      _selectedProfileImagePath = path;
    });
    _updateHasChanges();

    AppToast.showSuccess(context, '${file.name} selected successfully.');
  }

  void _focusField(FocusNode focusNode, TextEditingController controller) {
    focusNode.requestFocus();
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  Future<void> _loadProfile() async {
    final parentProvider = context.read<ParentProvider>();
    await parentProvider.loadParentProfile();
    if (!mounted) {
      return;
    }
    await _handleUnauthorized(parentProvider.lastStatusCode);
    if (!mounted) {
      return;
    }

    final profile = parentProvider.profile;
    if (profile != null) {
      _syncFormWithProfile(profile);
      return;
    }

    final fallbackProfile = _fallbackProfileFromSession();
    if (fallbackProfile != null) {
      _syncFormWithProfile(fallbackProfile);
      if ((parentProvider.errorMessage ?? '').trim().isNotEmpty) {
        AppToast.showInfo(
          context,
          'Your basic account details were loaded. Some profile fields could not be fetched from the server.',
        );
      }
    }
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

  Future<void> _saveProfile() async {
    final parentProvider = context.read<ParentProvider>();
    final currentProfile = parentProvider.profile ?? _initialProfile;
    if (currentProfile == null) {
      AppToast.showInfo(context, 'Load your profile before saving changes.');
      return;
    }

    final updatedProfile = ParentProfile(
      id: currentProfile.id,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      occupation: _occupationController.text.trim(),
      preferredHours: _hoursController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      primaryLocation: _locationController.text.trim(),
      profilePictureUrl: currentProfile.profilePictureUrl,
      status: currentProfile.status,
    );

    final selectedImagePath = _normalizeValue(_selectedProfileImagePath);
    final hadAvatarChange = selectedImagePath.isNotEmpty;
    final success = await parentProvider.updateParentProfile(
      updatedProfile,
      profilePicturePath: hadAvatarChange ? selectedImagePath : null,
    );
    if (!mounted) {
      return;
    }

    if (!success) {
      await _handleUnauthorized(parentProvider.lastStatusCode);
      if (!mounted) {
        return;
      }
      AppToast.showError(
        context,
        parentProvider.errorMessage ?? 'Unable to save your profile right now.',
        statusCode: parentProvider.lastStatusCode,
        fallbackMessage: 'Unable to save your profile right now.',
      );
      return;
    }

    final savedProfile = parentProvider.profile ?? updatedProfile;
    _syncFormWithProfile(savedProfile);

    AppToast.showSuccess(
      context,
      hadAvatarChange
          ? 'Profile and avatar updated successfully.'
          : (parentProvider.successMessage ?? 'Profile updated successfully.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildProfileBody(parentProvider),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileBody(ParentProvider parentProvider) {
    final hasLocalFallbackProfile = _initialProfile != null;

    if (parentProvider.isLoadingProfile &&
        parentProvider.profile == null &&
        !hasLocalFallbackProfile) {
      return _buildProfileSkeleton();
    }

    if (parentProvider.errorMessage != null &&
        parentProvider.profile == null &&
        !hasLocalFallbackProfile) {
      return Padding(
        padding: const EdgeInsets.only(top: 120),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildAvatarSection(),
        const SizedBox(height: 32),
        _buildFormField(
          label: 'Full Name',
          icon: Icons.person_outline,
          controller: _nameController,
          focusNode: _nameFocusNode,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          label: 'Occupation',
          icon: Icons.work_outline,
          controller: _occupationController,
          focusNode: _occupationFocusNode,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          label: 'Preferred Hours',
          icon: Icons.schedule_outlined,
          controller: _hoursController,
          focusNode: _hoursFocusNode,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          controller: _phoneController,
          focusNode: _phoneFocusNode,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          label: 'Primary Location',
          icon: Icons.location_on_outlined,
          controller: _locationController,
          focusNode: _locationFocusNode,
        ),
        const SizedBox(height: 12),
        _buildFormField(
          label: 'Email Address',
          icon: Icons.email_outlined,
          controller: _emailController,
          focusNode: _emailFocusNode,
        ),
        if (_hasChanges) ...[
          const SizedBox(height: 32),
          _buildSaveButton(parentProvider.isUpdatingProfile),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Center(child: AppSkeletonCircle(size: 120)),
        const SizedBox(height: 32),
        ...List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppSkeletonCard(
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  AppSkeletonBlock(width: 40, height: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBlock(width: 90, height: 12),
                        SizedBox(height: 8),
                        AppSkeletonBlock(width: double.infinity, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
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
    final localImagePath = _normalizeValue(_selectedProfileImagePath);
    final remoteImageUrl = _normalizeValue(_initialProfile?.profilePictureUrl);

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
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
                child: localImagePath.isNotEmpty
                    ? Image.file(File(localImagePath), fit: BoxFit.cover)
                    : remoteImageUrl.isNotEmpty
                    ? Image.network(
                        remoteImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/logo.png', fit: BoxFit.cover);
                        },
                      )
                    : Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _pickProfileImage,
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
    required FocusNode focusNode,
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
            child: Icon(icon, color: BabyCareTheme.primaryBerry, size: 20),
          ),
          const SizedBox(width: 12),

          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
            ),
          ),

          // Edit icon
          GestureDetector(
            onTap: () => _focusField(focusNode, controller),
            child: const Icon(
              Icons.edit_outlined,
              color: BabyCareTheme.primaryBerry,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  /// Save Changes button
  Widget _buildSaveButton(bool isSaving) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSaving ? null : _saveProfile,
          borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedSitters();
    });
  }

  Future<void> _loadSavedSitters() async {
    final parentProvider = context.read<ParentProvider>();
    await parentProvider.loadSavedSitters();
    if (!mounted) {
      return;
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

  void _showRemoveDialog(BabysitterProfile sitter) {
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
          'Are you sure you want to remove ${sitter.fullName} from your saved sitters?',
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
            onPressed: () async {
              final parentProvider = context.read<ParentProvider>();
              final success = await parentProvider.toggleSavedSitter(sitter);
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              if (!success) {
                await _handleUnauthorized(parentProvider.lastStatusCode);
                if (!context.mounted) {
                  return;
                }
                AppToast.showError(
                  context,
                  parentProvider.errorMessage ??
                      'Unable to update your saved sitters right now.',
                  statusCode: parentProvider.lastStatusCode,
                  fallbackMessage:
                      'Unable to update your saved sitters right now.',
                );
                return;
              }
              AppToast.showSuccess(
                context,
                parentProvider.successMessage ?? 'Saved list updated.',
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
    return Consumer<ParentProvider>(
      builder: (context, parentProvider, _) {
        final savedSitters = parentProvider.savedSitters;

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
                        onRefresh: _loadSavedSitters,
                        child: _buildSavedBody(parentProvider, savedSitters),
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

  Widget _buildSavedBody(
    ParentProvider parentProvider,
    List<BabysitterProfile> savedSitters,
  ) {
    if (parentProvider.isLoadingSavedSitters && savedSitters.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [_buildSavedSkeletonList()],
      );
    }

    if (parentProvider.errorMessage != null && savedSitters.isEmpty) {
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
                    parentProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: BabyCareTheme.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadSavedSitters,
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

    if (savedSitters.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [_buildEmptyState()],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      itemCount: savedSitters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sitter = savedSitters[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    SitterProfileParentViewScreen(babysitterId: sitter.id),
              ),
            );
          },
          child: _buildSitterCard(sitter),
        );
      },
    );
  }

  Widget _buildSavedSkeletonList() {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppSkeletonCard(
            child: Row(
              children: const [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBlock(width: 130, height: 16),
                      SizedBox(height: 8),
                      AppSkeletonBlock(width: 95, height: 12),
                      SizedBox(height: 8),
                      AppSkeletonBlock(width: 150, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                AppSkeletonCircle(size: 64),
              ],
            ),
          ),
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
  Widget _buildSitterCard(BabysitterProfile sitter) {
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
                  child: _buildProfileImage(sitter.profilePictureUrl),
                ),
              ),
              const SizedBox(width: 12),

              // Content
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
                    const SizedBox(height: 4),
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
                      (sitter.location ?? '').trim().isEmpty
                          ? 'Location not provided'
                          : sitter.location!,
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
            onTap: () => _showRemoveDialog(sitter),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BabyCareTheme.universalWhite,
                border: Border.all(color: BabyCareTheme.lightGrey, width: 2),
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
