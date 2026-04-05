import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/sitter_registration.dart';
import '../widgets/app_toast.dart';
import 'sitter_registration_step2.dart';

class SitterRegistrationStep1Screen extends StatefulWidget {
  final SitterRegistrationData registrationData;

  const SitterRegistrationStep1Screen({
    super.key,
    required this.registrationData,
  });

  @override
  State<SitterRegistrationStep1Screen> createState() =>
      _SitterRegistrationStep1ScreenState();
}

class _SitterRegistrationStep1ScreenState
    extends State<SitterRegistrationStep1Screen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _passwordController;

  String? _selectedGender;
  bool _hidePassword = true;

  final List<String> _genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.registrationData.fullName ?? '',
    );
    _emailController = TextEditingController(
      text: widget.registrationData.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.registrationData.phone ?? '',
    );
    _locationController = TextEditingController(
      text: widget.registrationData.location ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.registrationData.password ?? '',
    );
    _selectedGender = widget.registrationData.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    // Save data
    widget.registrationData.fullName = _fullNameController.text;
    widget.registrationData.email = _emailController.text;
    widget.registrationData.gender = _selectedGender;
    widget.registrationData.phone = _phoneController.text;
    widget.registrationData.location = _locationController.text;
    widget.registrationData.password = _passwordController.text;

    if (widget.registrationData.isStep1Valid()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SitterRegistrationStep2Screen(
            registrationData: widget.registrationData,
          ),
        ),
      );
    } else {
      AppToast.showInfo(context, 'Please fill all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: BabyCareTheme.universalWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Button & Title
              _buildHeader(),

              const SizedBox(height: 24),

              // Progress Bar (33%)
              _buildProgressBar(),

              const SizedBox(height: 32),

              // Form Fields
              _buildFormFields(size),

              const SizedBox(height: 32),

              // Next Button
              _buildNextButton(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with back button and title
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: BabyCareTheme.primaryBerry,
                  size: 28,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: BabyCareTheme.primaryBerry,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: BabyCareTheme.darkGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Progress bar showing 33% completion
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 1 of 3',
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: BabyCareTheme.darkGrey),
            ),
            Text(
              '33%',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: BabyCareTheme.primaryBerry,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.33,
            minHeight: 6,
            backgroundColor: BabyCareTheme.lightGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(
              BabyCareTheme.primaryBerry,
            ),
          ),
        ),
      ],
    );
  }

  /// Form fields container
  Widget _buildFormFields(Size size) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          children: [
            // Full Name
            _buildInputField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Email
            _buildInputField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            _buildGenderDropdown(),
            const SizedBox(height: 16),

            // Phone
            _buildPhoneField(),
            const SizedBox(height: 16),

            // Location
            _buildInputField(
              controller: _locationController,
              label: 'Location',
              hint: 'Enter your location',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            // Password
            _buildPasswordField(),
          ],
        ),
      ),
    );
  }

  /// Generic input field widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
            hintText: hint,
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

  /// Gender dropdown field
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: BabyCareTheme.darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: BabyCareTheme.lightGrey,
            borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
            border: Border.all(color: BabyCareTheme.lightGrey),
          ),
          child: DropdownButton<String>(
            value: _selectedGender,
            hint: const Text('Select gender'),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            icon: const Icon(
              Icons.expand_more,
              color: BabyCareTheme.primaryBerry,
            ),
            items: _genderOptions.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedGender = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  /// Phone field with +256 flag
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: BabyCareTheme.darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '700123456',
            hintStyle: TextStyle(
              color: BabyCareTheme.darkGrey.withValues(alpha: 0.5),
            ),
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '🇺🇬 +256',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
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

  /// Password field with eye toggle
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
            hintText: 'Enter a strong password',
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

  /// Next button
  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        gradient: BabyCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(BabyCareTheme.radiusLarge),
      ),
      child: ElevatedButton(
        onPressed: _onNextPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next: Work Preferences',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: BabyCareTheme.universalWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward,
              color: BabyCareTheme.universalWhite,
            ),
          ],
        ),
      ),
    );
  }
}
