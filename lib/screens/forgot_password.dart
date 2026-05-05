import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/auth_user.dart';
import '../providers/auth_provider.dart';
import '../services/clerk_password_reset_service.dart';
import '../widgets/app_toast.dart';
import 'parent_discover.dart';
import 'sitter_dashboard.dart';

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
  late final ClerkPasswordResetService _passwordResetService;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _passwordResetService = ClerkPasswordResetService();
    _identifierController = TextEditingController(
      text: widget.prefilledIdentifier?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordResetService.dispose();
    super.dispose();
  }

  Future<void> _requestResetCode({bool showSuccessToast = false}) async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      AppToast.showInfo(context, 'Enter the email for your account.');
      return;
    }

    if (!_looksLikeEmail(identifier)) {
      AppToast.showInfo(context, 'Enter a valid email address.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _passwordResetService.initiateEmailPasswordReset(identifier);
      if (!mounted) {
        return;
      }

      if (showSuccessToast) {
        AppToast.showSuccess(context, 'Another reset code has been sent.');
      }

      await _showResetCodeScreen(identifier);
    } on ClerkPasswordResetException catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.showError(
        context,
        error.message,
        fallbackMessage: 'Unable to start password reset right now.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _onContinuePressed() {
    return _requestResetCode();
  }

  Future<void> _showResetCodeScreen(String email) async {
    final resetEmail = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => _ResetPasswordCodeScreen(
          accountLabel: widget.accountLabel,
          email: email,
          passwordResetService: _passwordResetService,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (resetEmail != null && resetEmail.isNotEmpty) {
      Navigator.of(context).pop(resetEmail);
    }
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
              _buildRequestState(context, _isSubmitting),
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
                'We will send a Clerk reset code to the email address, then you can enter the code and choose a new password here in the app.',
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
          label: 'Send Reset Code',
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

class _ResetPasswordCodeScreen extends StatefulWidget {
  const _ResetPasswordCodeScreen({
    required this.accountLabel,
    required this.email,
    required this.passwordResetService,
  });

  final String accountLabel;
  final String email;
  final ClerkPasswordResetService passwordResetService;

  @override
  State<_ResetPasswordCodeScreen> createState() =>
      _ResetPasswordCodeScreenState();
}

class _ResetPasswordCodeScreenState extends State<_ResetPasswordCodeScreen> {
  late final TextEditingController _codeController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isSubmitting = false;
  bool _isResending = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onResendPressed() async {
    setState(() {
      _isResending = true;
    });

    try {
      await widget.passwordResetService.resendEmailPasswordReset(widget.email);
      if (!mounted) {
        return;
      }

      AppToast.showSuccess(context, 'Another reset code has been sent.');
    } on ClerkPasswordResetException catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.showError(
        context,
        error.message,
        fallbackMessage: 'Unable to send another reset code right now.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _onResetPressed() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      AppToast.showInfo(context, 'Enter the 6-digit reset code.');
      return;
    }

    if (password.length < 8) {
      AppToast.showInfo(
        context,
        'Choose a password with at least 8 characters.',
      );
      return;
    }

    if (password != confirmation) {
      AppToast.showInfo(context, 'Passwords do not match.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.passwordResetService.completeEmailPasswordReset(
        email: widget.email,
        code: code,
        newPassword: password,
      );
      if (!mounted) {
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        email: widget.email,
        password: password,
      );
      if (!mounted) {
        return;
      }

      if (!success) {
        AppToast.showError(
          context,
          authProvider.errorMessage ??
              'Password reset worked, but sign in failed.',
          statusCode: authProvider.lastStatusCode,
          fallbackMessage: 'Password reset worked, but sign in failed.',
          normalizeUnauthorized: false,
        );
        return;
      }

      final expectedRole = _expectedRole;
      if (expectedRole != null && authProvider.currentRole != expectedRole) {
        await authProvider.logout();
        if (!mounted) {
          return;
        }

        AppToast.showError(context, _roleMismatchMessage(expectedRole));
        return;
      }

      AppToast.showSuccess(
        context,
        'Password reset complete. You are signed in.',
      );
      _navigateAfterSuccessfulReset(authProvider.currentRole);
    } on ClerkPasswordResetException catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.showError(
        context,
        error.message,
        fallbackMessage: 'Unable to complete password reset right now.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  UserRole? get _expectedRole {
    switch (widget.accountLabel.trim().toLowerCase()) {
      case 'parent':
        return UserRole.parent;
      case 'babysitter':
      case 'sitter':
        return UserRole.babysitter;
      default:
        return null;
    }
  }

  String _roleMismatchMessage(UserRole expectedRole) {
    switch (expectedRole) {
      case UserRole.parent:
        return 'This account does not have parent access.';
      case UserRole.babysitter:
        return 'This account does not have babysitter access.';
      default:
        return 'This account does not have access to this app area.';
    }
  }

  void _navigateAfterSuccessfulReset(UserRole role) {
    switch (role) {
      case UserRole.parent:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ParentDiscoverScreen()),
          (route) => false,
        );
        return;
      case UserRole.babysitter:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SitterDashboardScreen(),
          ),
          (route) => false,
        );
        return;
      default:
        Navigator.of(context).pop(widget.email);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Icons.mark_email_read_outlined,
                  color: BabyCareTheme.universalWhite,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Reset Code',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the reset code sent to ${widget.email} to continue with your ${widget.accountLabel} account recovery.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: BabyCareTheme.darkGrey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: BabyCareTheme.universalWhite,
                  borderRadius: BorderRadius.circular(
                    BabyCareTheme.radiusMedium,
                  ),
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
                      'Choose your new password',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(
                            color: BabyCareTheme.primaryBerry,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter the 6-digit reset code, then set the password you want to use the next time you sign in.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: BabyCareTheme.darkGrey,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BabyCareTheme.lightPink,
                        borderRadius: BorderRadius.circular(
                          BabyCareTheme.radiusSmall,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next steps',
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: BabyCareTheme.primaryBerry,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 10),
                          _StepRow(
                            number: '1',
                            label:
                                'Open the reset email and copy the reset code.',
                          ),
                          const SizedBox(height: 10),
                          _StepRow(
                            number: '2',
                            label:
                                'Enter the code below and choose a new password.',
                          ),
                          const SizedBox(height: 10),
                          _StepRow(
                            number: '3',
                            label:
                                'BabyCare signs you in automatically after the reset succeeds.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Reset code',
                        prefixIcon: Icon(
                          Icons.password_rounded,
                          color: BabyCareTheme.primaryBerry,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: BabyCareTheme.primaryBerry,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: BabyCareTheme.primaryBerry,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmation,
                      decoration: InputDecoration(
                        labelText: 'Confirm new password',
                        prefixIcon: const Icon(
                          Icons.lock_reset_rounded,
                          color: BabyCareTheme.primaryBerry,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirmation = !_hideConfirmation;
                            });
                          },
                          icon: Icon(
                            _hideConfirmation
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: BabyCareTheme.primaryBerry,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _PrimaryActionButton(
                label: 'Reset Password',
                onPressed: _onResetPressed,
                isLoading: _isSubmitting,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isResending ? null : _onResendPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: BabyCareTheme.primaryBerry),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      BabyCareTheme.radiusLarge,
                    ),
                  ),
                ),
                child: _isResending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BabyCareTheme.primaryBerry,
                          ),
                        ),
                      )
                    : Text(
                        'Send Another Code',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: BabyCareTheme.primaryBerry,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: BabyCareTheme.primaryBerry,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: BabyCareTheme.universalWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: BabyCareTheme.darkGrey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final Future<void> Function() onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
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
