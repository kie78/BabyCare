import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'sitter_login.dart';
import 'parent_login.dart';

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  final List<_FeatureCard> features = const [
    _FeatureCard(
      title: 'Connections',
      description: 'Connect seamlessly with trusted families and caregivers.',
      iconData: Icons.handshake_outlined,
      backgroundColor: BabyCareTheme.lightPink,
    ),
    _FeatureCard(
      title: 'Safety',
      description: 'Every sitter is verified and approved by our admin team.',
      iconData: Icons.verified_user_outlined,
      backgroundColor: BabyCareTheme.lightPurple,
    ),
    _FeatureCard(
      title: 'Privacy',
      description:
          'Secure messaging and encrypted communications for peace of mind.',
      iconData: Icons.lock_outline_rounded,
      backgroundColor: BabyCareTheme.lightRed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onParentPressed() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ParentLoginScreen()));
  }

  void _onSitterPressed() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SitterLoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 700;
    final headerToCardsSpacing = isCompact ? 16.0 : 22.0;
    final cardsToDotsSpacing = isCompact ? 14.0 : 18.0;
    final dotsToButtonsSpacing = isCompact ? 8.0 : 12.0;

    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = (constraints.maxHeight * (isCompact ? 0.34 : 0.36))
              .clamp(210.0, 280.0);

          return Column(
            children: [
              const SizedBox(height: 32),
              _buildHeader(size),
              SizedBox(height: headerToCardsSpacing),
              SizedBox(height: cardHeight, child: _buildCarousel(size)),
              SizedBox(height: cardsToDotsSpacing),
              _buildDotIndicators(),
              SizedBox(height: dotsToButtonsSpacing),
              _buildRoleSelectors(size),
              SizedBox(height: isCompact ? 8 : 12),
            ],
          );
        },
      ),
    );
  }

  /// Header with logo and branding
  Widget _buildHeader(Size size) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          // Circular Logo
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BabyCareTheme.primaryGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ClipOval(
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Branding
          Text(
            'BabyCare',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: BabyCareTheme.primaryBerry,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Managing trusted care,\none family at a time',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: BabyCareTheme.darkGrey,
              height: 1.4,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Carousel with swipeable feature cards
  Widget _buildCarousel(Size size) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCardItem(features[index], size);
      },
    );
  }

  /// Individual feature card in carousel
  Widget _buildFeatureCardItem(_FeatureCard feature, Size size) {
    final isCompact = size.height < 700;
    final cardPadding = isCompact ? 16.0 : 20.0;
    final iconSize = isCompact ? 48.0 : 56.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          color: BabyCareTheme.universalWhite,
          border: Border.all(color: feature.backgroundColor, width: 2),
          borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Circle
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: feature.backgroundColor,
                  ),
                  child: Center(
                    child: Icon(
                      feature.iconData,
                      size: isCompact ? 26 : 30,
                      color: BabyCareTheme.primaryBerry,
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 10 : 12),

                // Title
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: BabyCareTheme.primaryBerry,
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 22 : 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isCompact ? 8 : 10),

                // Description
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: BabyCareTheme.darkGrey,
                    height: 1.45,
                    fontSize: isCompact ? 15 : 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dot indicators for carousel
  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        features.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? BabyCareTheme.primaryBerry
                : BabyCareTheme.lightGrey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Role selection buttons
  Widget _buildRoleSelectors(Size size) {
    final isCompact = size.height < 700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Parent CTA (Berry/Magenta Gradient)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: BabyCareTheme.primaryGradient,
              borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
            ),
            child: ElevatedButton(
              onPressed: _onParentPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: isCompact ? 14 : 16),
              ),
              child: Text(
                'I am a Parent',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: BabyCareTheme.universalWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sitter CTA (White with Berry Border)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _onSitterPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: BabyCareTheme.primaryBerry,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusLarge,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: isCompact ? 14 : 16),
              ),
              child: Text(
                'I am a Babysitter',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for feature card
class _FeatureCard {
  final String title;
  final String description;
  final IconData iconData;
  final Color backgroundColor;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.iconData,
    required this.backgroundColor,
  });
}
