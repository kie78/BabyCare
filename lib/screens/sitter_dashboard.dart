import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/profile_view.dart';
import '../providers/auth_provider.dart';
import '../providers/babysitter_dashboard_provider.dart';
import '../widgets/app_skeleton.dart';
import '../widgets/app_toast.dart';
import 'gateway_screen.dart';
import 'parent_profile_sitter_view.dart';
import 'sitter_account.dart';
import 'sitter_messages.dart';

class SitterDashboardScreen extends StatefulWidget {
  const SitterDashboardScreen({super.key});

  @override
  State<SitterDashboardScreen> createState() => _SitterDashboardScreenState();
}

class _SitterDashboardScreenState extends State<SitterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    final dashboardProvider = context.read<BabysitterDashboardProvider>();
    await dashboardProvider.loadDashboard();
    if (!mounted) {
      return;
    }
    await _handleUnauthorized(dashboardProvider.lastStatusCode);
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

  Future<void> _onAvailabilityToggle(bool value) async {
    final dashboardProvider = context.read<BabysitterDashboardProvider>();
    final success = await dashboardProvider.updateAvailability(value);
    if (!mounted) {
      return;
    }

    if (!success) {
      await _handleUnauthorized(dashboardProvider.lastStatusCode);
      if (!mounted) {
        return;
      }
      AppToast.showError(
        context,
        dashboardProvider.errorMessage ?? 'Unable to update your work status right now.',
        statusCode: dashboardProvider.lastStatusCode,
        fallbackMessage: 'Unable to update your work status right now.',
      );
      return;
    }

    AppToast.showSuccess(
      context,
      dashboardProvider.successMessage ?? 'Work status updated.',
    );
  }

  void _onMessagesPressed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SitterMessagesScreen()),
    );
  }

  void _onVisitorPressed(ProfileView visitor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ParentProfileSitterViewScreen(
          parentId: visitor.id,
          parentName: visitor.viewerName,
          profileImage: (visitor.profileImageUrl ?? '').trim(),
          location: (visitor.location ?? 'Location not provided').trim(),
          job: (visitor.occupation ?? 'Parent').trim(),
          hours: (visitor.preferredHours ?? 'Hours not provided').trim(),
          phoneNumber: (visitor.phone ?? '').trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BabysitterDashboardProvider>(
      builder: (context, dashboardProvider, _) {
        return Scaffold(
          backgroundColor: BabyCareTheme.universalWhite,
          extendBody: true,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: _buildHeader(dashboardProvider.profile),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadDashboard,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildDashboardBody(dashboardProvider),
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

  Widget _buildDashboardBody(BabysitterDashboardProvider dashboardProvider) {
    if (dashboardProvider.isLoading && dashboardProvider.profile == null) {
      return _buildDashboardSkeleton();
    }

    if (dashboardProvider.errorMessage != null &&
        dashboardProvider.profile == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 160),
        child: Center(
          child: Column(
            children: [
              Text(
                dashboardProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadDashboard,
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
        const SizedBox(height: 16),
        _buildAvailabilityCard(dashboardProvider),
        const SizedBox(height: 24),
        _buildWeeklyReachCard(dashboardProvider.weeklyViews),
        const SizedBox(height: 32),
        _buildVisitorsSection(dashboardProvider.profileViews),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHeader(dynamic profile) {
    final name = profile?.fullName?.toString() ?? 'Babysitter';
    final profileImageUrl = profile?.profilePictureUrl?.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hello, ${name.split(' ').first}',
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
              child: _buildProfileImage(profileImageUrl),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppSkeletonBlock(width: 170, height: 26),
            AppSkeletonCircle(size: 56),
          ],
        ),
        const SizedBox(height: 24),
        AppSkeletonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppSkeletonBlock(width: 110, height: 14),
              SizedBox(height: 14),
              AppSkeletonBlock(width: double.infinity, height: 52),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppSkeletonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppSkeletonBlock(width: 120, height: 14),
              SizedBox(height: 16),
              AppSkeletonBlock(width: 80, height: 28),
              SizedBox(height: 10),
              AppSkeletonBlock(width: 150, height: 12),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const AppSkeletonBlock(width: 128, height: 16),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppSkeletonCard(
              child: Row(
                children: const [
                  AppSkeletonCircle(size: 52),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBlock(width: 120, height: 14),
                        SizedBox(height: 8),
                        AppSkeletonBlock(width: 160, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
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

  Widget _buildAvailabilityCard(BabysitterDashboardProvider dashboardProvider) {
    final isAvailable = dashboardProvider.isAvailable;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAvailable ? BabyCareTheme.lightPink : BabyCareTheme.lightGrey,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        border: Border.all(
          color: isAvailable
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
                isAvailable ? 'You are available' : 'You are unavailable',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: isAvailable
                      ? BabyCareTheme.primaryBerry
                      : BabyCareTheme.darkGrey.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Switch(
            value: isAvailable,
            onChanged: dashboardProvider.isUpdatingAvailability
                ? null
                : _onAvailabilityToggle,
            activeColor: BabyCareTheme.primaryBerry,
            activeTrackColor: BabyCareTheme.primaryBerry.withValues(alpha: 0.3),
            inactiveThumbColor: BabyCareTheme.darkGrey.withValues(alpha: 0.3),
            inactiveTrackColor: BabyCareTheme.darkGrey.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReachCard(int weeklyReach) {
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
                  '$weeklyReach profile views this week',
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

  Widget _buildVisitorsSection(List<ProfileView> visitors) {
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
        if (visitors.isEmpty)
          Text(
            'No profile views have been recorded yet.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visitors.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final visitor = visitors[index];
              return GestureDetector(
                onTap: () => _onVisitorPressed(visitor),
                child: _buildVisitorCard(visitor),
              );
            },
          ),
      ],
    );
  }

  Widget _buildVisitorCard(ProfileView visitor) {
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
              child: _buildProfileImage(visitor.profileImageUrl),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.viewerName,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (visitor.occupation ?? 'Parent').trim(),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Timestamp
          Text(
            _formatDateTime(visitor.viewedAt),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Now';
    }

    final difference = DateTime.now().difference(value);
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
