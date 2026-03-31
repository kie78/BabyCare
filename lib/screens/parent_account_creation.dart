import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'parent_login.dart';

class ParentAccountCreationScreen extends StatefulWidget {
  const ParentAccountCreationScreen({super.key});

  @override
  State<ParentAccountCreationScreen> createState() =>
      _ParentAccountCreationScreenState();
}

class _ParentAccountCreationScreenState
    extends State<ParentAccountCreationScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _occupationController;
  late TextEditingController _emailController;
  late TextEditingController _preferredHoursController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _passwordController;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _occupationController = TextEditingController();
    _emailController = TextEditingController();
    _preferredHoursController = TextEditingController();
    _phoneController = TextEditingController(text: '+256 ');
    _locationController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _occupationController.dispose();
    _emailController.dispose();
    _preferredHoursController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccountPressed() async {
    // Validation
    if (_fullNameController.text.isEmpty ||
        _occupationController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _preferredHoursController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerParent(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      occupation: _occupationController.text.trim(),
      preferredHours: _preferredHoursController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'We could not create your account right now.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully. Please log in.'),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ParentLoginScreen()),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
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

              // Header
              Text(
                'Join BabyCare',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: BabyCareTheme.primaryBerry,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to discover trusted sitters',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
              ),

              const SizedBox(height: 32),

              // Form Fields
              _buildFormField(
                label: 'Full Name',
                controller: _fullNameController,
                icon: Icons.person_outline,
                hintText: 'Enter your full name',
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Occupation',
                controller: _occupationController,
                icon: Icons.work_outline,
                hintText: 'Enter your occupation',
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Email Address',
                controller: _emailController,
                icon: Icons.email_outlined,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Preferred Hours',
                controller: _preferredHoursController,
                icon: Icons.schedule_outlined,
                hintText: 'e.g., 8 AM - 5 PM',
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                hintText: '+256 700 123 456',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildFormField(
                label: 'Primary Location',
                controller: _locationController,
                icon: Icons.location_on_outlined,
                hintText: 'Enter your location',
              ),
              const SizedBox(height: 16),

              _buildPasswordField(),

              const SizedBox(height: 32),

              // Create Account Button
              _buildCreateAccountButton(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Generic form field with icon and label
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: BabyCareTheme.darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, color: BabyCareTheme.primaryBerry),
            filled: true,
            fillColor: BabyCareTheme.lightGrey,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
              borderSide: const BorderSide(color: BabyCareTheme.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
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
    );
  }

  /// Password field with visibility toggle
  Widget _buildPasswordField() {
    return Column(
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
            hintText: 'Create a strong password',
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
              borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
              borderSide: const BorderSide(color: BabyCareTheme.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
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
    );
  }

  /// Create Account Button
  Widget _buildCreateAccountButton() {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _onCreateAccountPressed,
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
                'Create Account',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: BabyCareTheme.universalWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
