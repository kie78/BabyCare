import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'gateway_screen.dart';
import 'parent_account_creation.dart';
import 'parent_discover.dart';

class ParentLoginScreen extends StatefulWidget {
  const ParentLoginScreen({super.key});

  @override
  State<ParentLoginScreen> createState() => _ParentLoginScreenState();
}

class _ParentLoginScreenState extends State<ParentLoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // TODO: Authenticate with backend
    // For now, simulate login and navigate to parent dashboard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ParentDiscoverScreen()),
    );
  }

  void _onForgotPasswordPressed() {
    // TODO: Implement forgot password flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot password flow not yet implemented')),
    );
  }

  void _onCreateAccountPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ParentAccountCreationScreen(),
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

              // Logo with Heart Icon
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
                'Login to your parent account',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Form Fields
              _buildFormFields(),

              const SizedBox(height: 24),

              // Login Button
              _buildLoginButton(),

              const SizedBox(height: 16),

              // Forgot Password Link
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

              const SizedBox(height: 32),

              // Create Account Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to BabyCare? ',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: BabyCareTheme.darkGrey,
                    ),
                  ),
                  GestureDetector(
                    onTap: _onCreateAccountPressed,
                    child: Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: BabyCareTheme.primaryBerry,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo with app icon
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

  /// Form fields (email & password)
  Widget _buildFormFields() {
    return Column(
      children: [
        // Phone or Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone or Email',
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
                hintText: 'Enter your phone or email',
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: ElevatedButton(
        onPressed: _onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Log In',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: BabyCareTheme.universalWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
