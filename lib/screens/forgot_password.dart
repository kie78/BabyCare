import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.accountLabel,
    this.prefilledIdentifier,
    this.identifierLabel = 'Email address',
    this.identifierHint = 'Enter your email address',
  });

  final String accountLabel;
  final String? prefilledIdentifier;
  final String identifierLabel;
  final String identifierHint;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _identifierController;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController(
      text: widget.prefilledIdentifier?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _onContinuePressed() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      AppToast.showInfo(context, 'Enter the email for your account.');
      return;
    }

    if (!_looksLikeEmail(identifier)) {
      AppToast.showInfo(context, 'Enter a valid email address.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(email: identifier);
    if (!mounted) {
      return;
    }

    if (!success) {
      AppToast.showError(
        context,
        authProvider.errorMessage ?? 'Unable to send a reset link right now.',
        statusCode: authProvider.lastStatusCode,
        fallbackMessage: 'Unable to send a reset link right now.',
      );
      return;
    }

    setState(() {
      _showConfirmation = true;
    });
  }

  bool _looksLikeEmail(String value) {
    final parts = value.split('@');
    if (parts.length != 2) {
      return false;
    }

    final localPart = parts.first.trim();
    final domainPart = parts.last.trim();
    return localPart.isNotEmpty &&
        domainPart.contains('.') &&
        !domainPart.startsWith('.') &&
        !domainPart.endsWith('.');
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: BabyCareTheme.primaryBerry,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: BabyCareTheme.lightPink,
                ),
              ),
              const SizedBox(height: 28),
              _buildHeader(context),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _showConfirmation
                    ? _buildConfirmationState(context)
                    : _buildRequestState(context, isSubmitting),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: BabyCareTheme.primaryGradient,
            boxShadow: const [
              BoxShadow(
                color: Color(0x2AB83D87),
                blurRadius: 24,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            color: BabyCareTheme.universalWhite,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: BabyCareTheme.primaryBerry,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter the email linked to your ${widget.accountLabel} account and we will guide you through the next recovery step.',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: BabyCareTheme.darkGrey,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestState(BuildContext context, bool isSubmitting) {
    return Column(
      key: const ValueKey('request-state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: BabyCareTheme.lightPink,
            borderRadius: BorderRadius.circular(BabyCareTheme.radiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What happens next',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'If an account with that email exists, we will send a password reset link to the inbox. The reset page is handled outside the app.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: BabyCareTheme.darkGrey,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.identifierLabel,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: BabyCareTheme.darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _identifierController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: widget.identifierHint,
            hintStyle: TextStyle(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.45),
            ),
            prefixIcon: const Icon(
              Icons.alternate_email_rounded,
              color: BabyCareTheme.primaryBerry,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          context,
          label: 'Send Reset Link',
          onPressed: _onContinuePressed,
          isLoading: isSubmitting,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Back to Login',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BabyCareTheme.primaryBerry,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationState(BuildContext context) {
    return Column(
      key: const ValueKey('confirmation-state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: BabyCareTheme.universalWhite,
            borderRadius: BorderRadius.circular(BabyCareTheme.radiusMedium),
            border: Border.all(color: BabyCareTheme.lightPink),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: BabyCareTheme.lightPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: BabyCareTheme.primaryBerry,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Check your inbox',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'If an account with ${_identifierController.text.trim()} exists, a password reset link has been sent. Use that email link to continue securely.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: BabyCareTheme.darkGrey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'For security, BabyCare always shows the same confirmation message and does not reveal whether the email is registered.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: BabyCareTheme.darkGrey,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          context,
          label: 'Back to Login',
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _showConfirmation = false;
              });
            },
            child: Text(
              'Use a different email',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: BabyCareTheme.primaryBerry,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String label,
    required Future<void> Function() onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
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
                label,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: BabyCareTheme.universalWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
