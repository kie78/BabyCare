import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/auth_user.dart';
import '../providers/auth_provider.dart';
import '../models/sitter_registration.dart';
import '../widgets/app_toast.dart';
import 'forgot_password.dart';
import 'sitter_dashboard.dart';
import 'sitter_registration_step1.dart';
import 'gateway_screen.dart';

class SitterLoginScreen extends StatefulWidget {
  const SitterLoginScreen({
    super.key,
    this.successMessage,
    this.showPendingApprovalBanner = false,
  });

  final String? successMessage;
  final bool showPendingApprovalBanner;

  @override
  State<SitterLoginScreen> createState() => _SitterLoginScreenState();
}

class _SitterLoginScreenState extends State<SitterLoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        AppToast.showSuccess(context, widget.successMessage!);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AppToast.showInfo(context, 'Please fill all fields');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      if (authProvider.currentRole == UserRole.babysitter) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SitterDashboardScreen(),
          ),
          (route) => false,
        );
        return;
      }

      await authProvider.logout();
      if (!mounted) {
        return;
      }
      AppToast.showError(
        context,
        'This account does not have babysitter access.',
      );
      return;
    }

    if (authProvider.lastStatusCode == 403) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SitterPendingConfirmationScreen(),
        ),
      );
      return;
    }

    AppToast.showError(
      context,
      authProvider.errorMessage ?? 'Login failed. Please try again.',
      statusCode: authProvider.lastStatusCode,
      fallbackMessage: 'Login failed. Please try again.',
      normalizeUnauthorized: false,
    );
  }

  void _onForgotPasswordPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(
          accountLabel: 'babysitter',
          prefilledIdentifier: _emailController.text,
          identifierLabel: 'Email address',
          identifierHint: 'Enter your babysitter account email',
        ),
      ),
    );
  }

  void _onSignUpPressed() {
    final registrationData = SitterRegistrationData();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SitterRegistrationStep1Screen(registrationData: registrationData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GatewayScreen(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 24),
                    child: Icon(
                      Icons.arrow_back,
                      color: BabyCareTheme.primaryBerry,
                      size: 28,
                    ),
                  ),
                ),
              ),

              // Logo
              _buildLogo(),

              const SizedBox(height: 48),

              // Title
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Login to your babysitter account',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              if (widget.showPendingApprovalBanner) ...[
                _buildStatusAlert(),
                const SizedBox(height: 32),
              ],

              // Form Fields
              _buildFormFields(),

              const SizedBox(height: 24),

              // Login Button
              _buildLoginButton(),

              const SizedBox(height: 16),

              // Forgot Password & Sign Up Links
              _buildBottomLinks(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo with branding
  Widget _buildLogo() {
    return Column(
      children: [
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
        const SizedBox(height: 16),
        Text(
          'BabyCare',
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: BabyCareTheme.primaryBerry,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Status alert card
  Widget _buildStatusAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightPurple,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        border: Border.all(color: BabyCareTheme.lightPurple),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: BabyCareTheme.primaryBerry,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your account is pending admin approval.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: BabyCareTheme.darkGrey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Form fields (email & password)
  Widget _buildFormFields() {
    return Column(
      children: [
        // Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: BabyCareTheme.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: TextStyle(
                  color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: BabyCareTheme.primaryBerry,
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
          ],
        ),

        const SizedBox(height: 16),

        // Password
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: BabyCareTheme.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(
                  color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: BabyCareTheme.primaryBerry,
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                  child: Icon(
                    _hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: BabyCareTheme.primaryBerry,
                  ),
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
          ],
        ),
      ],
    );
  }

  /// Login button
  Widget _buildLoginButton() {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    BabyCareTheme.universalWhite,
                  ),
                ),
              )
            : Text(
                'Login',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: BabyCareTheme.universalWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Bottom navigation links
  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _onForgotPasswordPressed,
          child: Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: _onSignUpPressed,
          child: Text(
            'Sign Up',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sitter Pending Confirmation Screen
class SitterPendingConfirmationScreen extends StatefulWidget {
  const SitterPendingConfirmationScreen({super.key});

  @override
  State<SitterPendingConfirmationScreen> createState() =>
      _SitterPendingConfirmationScreenState();
}

class _SitterPendingConfirmationScreenState
    extends State<SitterPendingConfirmationScreen> {
  Future<void> _onLogOutPressed() async {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Hourglass Illustration
              _buildHourglassIllustration(),

              const SizedBox(height: 48),

              // Title
              Text(
                'Application Under Review',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We are verifying your documents.\nThis will take a bit of time.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: BabyCareTheme.darkGrey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Tracking Cards
              _buildTrackingCard(
                'DOCUMENTS',
                '3 Files Received',
                Icons.check_circle,
              ),
              const SizedBox(height: 12),
              _buildTrackingCard(
                'VERIFICATION',
                'In Progress',
                Icons.hourglass_empty,
              ),

              const SizedBox(height: 48),

              // Log Out Button (Centered)
              SizedBox(
                width: 200,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: BabyCareTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      BabyCareTheme.radiusLarge,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _onLogOutPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.exit_to_app,
                          color: BabyCareTheme.universalWhite,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: BabyCareTheme.universalWhite,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Hourglass illustration
  Widget _buildHourglassIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: BabyCareTheme.primaryBerry,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.hourglass_bottom,
          color: BabyCareTheme.universalWhite,
          size: 64,
        ),
      ),
    );
  }

  /// Tracking card
  Widget _buildTrackingCard(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabyCareTheme.lightGrey,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
        border: Border.all(color: BabyCareTheme.lightGrey),
      ),
      child: Row(
        children: [
          Icon(icon, color: BabyCareTheme.primaryBerry, size: 28),
          const SizedBox(width: 16),
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
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
